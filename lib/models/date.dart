class Month {
  String label;

  Month(this.label);
}

class Day {
  String label;

  Day(this.label);
}

var listMonths = [
  {"label": "Jan"},
  {"label": "Feb"},
  {"label": "Mar"},
  {"label": "Apr"},
  {"label": "May"},
  {"label": "Jun"},
  {"label": "Jul"},
  {"label": "Aug"},
  {"label": "Sep"},
  {"label": "Oct"},
  {"label": "Nov"},
  {"label": "Dec"},
];
var listDays = [
  {"label": "Mon"},
  {"label": "Tue"},
  {"label": "Wed"},
  {"label": "Thu"},
  {"label": "Fri"},
  {"label": "Sat"},
  {"label": "Sun"},
];

List<Month> months = listMonths.map((item) => Month(item['label'] as String)).toList();
List<Day> days = listDays.map((item) => Day(item['label'] as String)).toList();
