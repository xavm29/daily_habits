class Goal{
  static const kDaily = 1;
  static const kWeekly = 2;
  static const kMonthly = 3;

  static const kMonday = 1;
  static const kTuesday = 2;
  static const kWednesday = 3;
  static const kThursday = 4;
  static const kFriday = 5;
  static const kSaturday = 6;
  static const kSunday = 7;

  late int id;
  late String title;
  late String number;
  late String category;
  late int periodic;
  late List<int> weekDays;
  late DateTime endDate;
  late DateTime hourReminder;

  Goal (this.id,this.title,this.number,this.category,this.periodic,this.weekDays,this.endDate,this.hourReminder);
  Goal.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    number= json['completed'];
    category= json['category'];
    periodic= json['periodic'];
    weekDays= json['weekDays'];
    endDate= json['endDate'];
    hourReminder= json['hourReminder'];
  }
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'number': number,
      'category': category,
      'periodic': periodic,
      'weekDays': weekDays,
      'endDate': endDate,
      'hourReminder': hourReminder
    };
  }
}