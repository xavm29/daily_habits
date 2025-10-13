import 'package:daily_habits/services/google_auth_service.dart';
import 'package:daily_habits/services/local_storage_service.dart';
import 'package:daily_habits/styles/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_data.dart';
import '../models/goals_model.dart';
import '../models/completed_goal.dart';
import '../services/firebase_service.dart';
import '../services/analytics_service.dart';
import '../services/crashlytics_service.dart';
import 'home.dart';

class LoginCustomScreen extends StatefulWidget {
  const LoginCustomScreen({Key? key}) : super(key: key);

  @override
  State<LoginCustomScreen> createState() => _LoginCustomScreenState();
}

class _LoginCustomScreenState extends State<LoginCustomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final userCredential = await GoogleAuthService.instance.signInWithGoogle();

      if (userCredential != null) {
        // Track analytics
        try {
          await AnalyticsService.instance.logLogin(method: 'google');
          await AnalyticsService.instance.setUserId(userCredential.user!.uid);
          await CrashlyticsService.instance.setUserId(userCredential.user!.uid);
          await CrashlyticsService.instance.setUserProperties(
            email: userCredential.user!.email,
            userId: userCredential.user!.uid,
          );
        } catch (e, stackTrace) {
          await CrashlyticsService.instance.recordAuthError(e, stackTrace);
        }

        // Check if user had local data and sync it
        if (await LocalStorageService.instance.hasLocalData()) {
          await _syncLocalDataToFirebase();
        }

        if (!mounted) return;

        // Navigate to home
        var userData = Provider.of<UserData>(context, listen: false);
        FirebaseService.instance.getCompletedTasks().then((value) {
          userData.tasks = value;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      }
    } catch (e, stackTrace) {
      await CrashlyticsService.instance.recordAuthError(e, stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing in: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential;
      if (_isSignUp) {
        // Sign up
        userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        // Track sign up
        try {
          await AnalyticsService.instance.logSignUp(method: 'email');
          await AnalyticsService.instance.setUserId(userCredential.user!.uid);
          await CrashlyticsService.instance.setUserId(userCredential.user!.uid);
          await CrashlyticsService.instance.setUserProperties(
            email: userCredential.user!.email,
            userId: userCredential.user!.uid,
          );
        } catch (e, stackTrace) {
          await CrashlyticsService.instance.recordAuthError(e, stackTrace);
        }
      } else {
        // Sign in
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        // Track login
        try {
          await AnalyticsService.instance.logLogin(method: 'email');
          await AnalyticsService.instance.setUserId(userCredential.user!.uid);
          await CrashlyticsService.instance.setUserId(userCredential.user!.uid);
          await CrashlyticsService.instance.setUserProperties(
            email: userCredential.user!.email,
            userId: userCredential.user!.uid,
          );
        } catch (e, stackTrace) {
          await CrashlyticsService.instance.recordAuthError(e, stackTrace);
        }
      }

      // Check if user had local data and sync it
      if (await LocalStorageService.instance.hasLocalData()) {
        await _syncLocalDataToFirebase();
      }

      if (!mounted) return;

      // Navigate to home
      var userData = Provider.of<UserData>(context, listen: false);
      FirebaseService.instance.getCompletedTasks().then((value) {
        userData.tasks = value;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    } catch (e, stackTrace) {
      await CrashlyticsService.instance.recordAuthError(e, stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _syncLocalDataToFirebase() async {
    try {
      // Get local data
      final localData = await LocalStorageService.instance.getDataForSync();

      // Sync goals
      for (var goalData in localData['goals']) {
        // Convert to Goal object and save to Firebase
        final goal = Goal.fromJson(goalData);
        await FirebaseService.instance.saveGoal(goal);
      }

      // Sync completed tasks
      for (var taskData in localData['tasks']) {
        // Convert to CompletedTask object and save to Firebase
        final task = CompletedTask.fromJson(taskData);
        await FirebaseService.instance.saveCompletedGoals(task);
      }

      // Clear local data after successful sync
      await LocalStorageService.instance.clearLocalData();

      // Track successful sync
      await AnalyticsService.instance.logSyncData(success: true);
    } catch (e, stackTrace) {
      await CrashlyticsService.instance.recordSyncError(e, stackTrace);
      await AnalyticsService.instance.logSyncData(success: false, error: e.toString());
      print('Error syncing local data: $e');
    }
  }

  void _handleSkip() {
    // Track that user skipped registration
    AnalyticsService.instance.logCustomEvent(
      eventName: 'skip_registration',
      parameters: {'from_screen': 'login'},
    );

    // User wants to use the app without registration
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Home()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primarys,
              AppColors.primarys.withOpacity(0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/icon.png',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 32),

                  // Welcome text
                  Text(
                    _isSignUp ? 'Create Account' : 'Welcome Back',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isSignUp
                        ? 'Sign up to save your progress'
                        : 'Sign in to continue',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Form card
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Email field
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Password field
                            TextFormField(
                              controller: _passwordController,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(Icons.lock),
                                border: OutlineInputBorder(),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Email Sign In/Up Button
                            ElevatedButton(
                              onPressed: _isLoading ? null : _handleEmailAuth,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primarys,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      _isSignUp ? 'Sign Up' : 'Sign In',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                            ),
                            const SizedBox(height: 16),

                            // Toggle Sign In/Up
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isSignUp = !_isSignUp;
                                });
                              },
                              child: Text(
                                _isSignUp
                                    ? 'Already have an account? Sign In'
                                    : 'Don\'t have an account? Sign Up',
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Divider
                            Row(
                              children: [
                                const Expanded(child: Divider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Google Sign In Button
                            OutlinedButton.icon(
                              onPressed: _isLoading ? null : _handleGoogleSignIn,
                              icon: Image.asset(
                                'assets/images/icon.png', // Replace with Google icon
                                height: 24,
                                width: 24,
                              ),
                              label: const Text('Continue with Google'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Skip button
                  TextButton(
                    onPressed: _handleSkip,
                    child: const Text(
                      'Skip for now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You can register later to sync your data',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
