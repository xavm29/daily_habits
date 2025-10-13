import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/friend_model.dart';

class FriendService {
  static final FriendService instance = FriendService._internal();
  FriendService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Send friend request
  Future<void> sendFriendRequest(String toUserId, String toUserName) async {
    if (currentUserId == null) return;

    final currentUser = _auth.currentUser!;
    final request = FriendRequest(
      fromUserId: currentUserId!,
      toUserId: toUserId,
      fromUserName: currentUser.displayName ?? 'User',
      fromUserPhoto: currentUser.photoURL ?? '',
      createdAt: DateTime.now(),
    );

    await _firestore.collection('friendRequests').add(request.toJson());
  }

  // Get pending friend requests for current user
  Stream<List<FriendRequest>> getPendingRequests() {
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('friendRequests')
        .where('toUserId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final request = FriendRequest.fromJson(doc.data());
        request.id = doc.id;
        return request;
      }).toList();
    });
  }

  // Accept friend request
  Future<void> acceptFriendRequest(FriendRequest request) async {
    if (currentUserId == null) return;

    // Update request status
    await _firestore
        .collection('friendRequests')
        .doc(request.id)
        .update({'status': 'accepted'});

    // Add to both users' friends lists
    final batch = _firestore.batch();

    // Add friend to current user's friends
    final currentUserFriend = Friend(
      userId: request.fromUserId,
      userName: request.fromUserName,
      userPhoto: request.fromUserPhoto,
      addedAt: DateTime.now(),
    );
    batch.set(
      _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('friends')
          .doc(request.fromUserId),
      currentUserFriend.toJson(),
    );

    // Add current user to friend's friends list
    final currentUser = _auth.currentUser!;
    final friendUserFriend = Friend(
      userId: currentUserId!,
      userName: currentUser.displayName ?? 'User',
      userPhoto: currentUser.photoURL ?? '',
      addedAt: DateTime.now(),
    );
    batch.set(
      _firestore
          .collection('users')
          .doc(request.fromUserId)
          .collection('friends')
          .doc(currentUserId),
      friendUserFriend.toJson(),
    );

    await batch.commit();
  }

  // Reject friend request
  Future<void> rejectFriendRequest(String requestId) async {
    await _firestore
        .collection('friendRequests')
        .doc(requestId)
        .update({'status': 'rejected'});
  }

  // Get friends list
  Stream<List<Friend>> getFriends() {
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final friend = Friend.fromJson(doc.data());
        friend.id = doc.id;
        return friend;
      }).toList();
    });
  }

  // Search users by email
  Future<List<UserProfile>> searchUsersByEmail(String email) async {
    if (email.isEmpty) return [];

    final snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email.toLowerCase())
        .limit(10)
        .get();

    return snapshot.docs
        .map((doc) {
          final profile = UserProfile.fromJson(doc.data());
          profile.userId = doc.id;
          return profile;
        })
        .where((profile) => profile.userId != currentUserId)
        .toList();
  }

  // Remove friend
  Future<void> removeFriend(String friendId) async {
    if (currentUserId == null) return;

    final batch = _firestore.batch();

    // Remove from current user's friends
    batch.delete(
      _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('friends')
          .doc(friendId),
    );

    // Remove current user from friend's friends
    batch.delete(
      _firestore
          .collection('users')
          .doc(friendId)
          .collection('friends')
          .doc(currentUserId),
    );

    await batch.commit();
  }

  // Update user profile (for search purposes)
  Future<void> updateUserProfile(UserProfile profile) async {
    if (currentUserId == null) return;

    await _firestore
        .collection('users')
        .doc(currentUserId)
        .set(profile.toJson(), SetOptions(merge: true));
  }
}
