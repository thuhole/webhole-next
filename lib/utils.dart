Future<String> tokenParams(String token) async {
  return '&user_token=' + token;
}

bool isValidToken(String token) {
  return token != null && token.length == 32;
}

String getDateDiff(int diffValue) {
  int minute = 60;
  int hour = minute * 60;
  int day = hour * 24;
  int month = day * 30;
  int diffMonth = diffValue ~/ month;
  int diffWeek = diffValue ~/ (7 * day);
  int diffDay = diffValue ~/ day;
  int diffHour = diffValue ~/ hour;
  int diffMinute = diffValue ~/ minute;
  String result;

  if (diffValue < 0) {
    return ("错误时间");
  }
  if (diffMonth > 1) {
    result = (diffMonth).toString() + "月前";
  } else if (diffWeek > 1) {
    result = (diffWeek).toString() + "周前";
  } else if (diffDay > 1) {
    result = (diffDay).toString() + "天前";
  } else if (diffHour > 1) {
    result = (diffHour).toString() + "小时前";
  } else if (diffMinute > 1) {
    result = (diffMinute).toString() + "分钟前";
  } else {
    result = "不到1分钟之前";
  }
  return result;
}
