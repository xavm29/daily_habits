class Goal{
  late int id;
  late String title;
  late int number;
  late String category;
  late DateTime endDate;
  late DateTime hourReminder;
  Goal (this.id,this.title,this.number,this.category,this.endDate,this.hourReminder);
  Goal.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    number= json['completed'];
    category= json['category'];
    endDate= json['endDate'];
    hourReminder= json['hourReminder'];
  }
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'number': number,
      'category': category,
      'endDate': endDate,
      'hourReminder': hourReminder
    };
  }
}