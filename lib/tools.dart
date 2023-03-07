String getWeek (int date) {
  switch (date) {
    case 1:
      return '星期一';
    case 2:
      return '星期二';
    case 3:
      return '星期三';
    case 4:
      return '星期四';
    case 5:
      return '星期五';
    case 6:
      return '星期六';
    case 7:
      return '星期天';
    default:
      return '输入的日期不合法(<1 or >7)';
  }
}

getPlanDeadline(DateTime date) {
  int deadline = date.day - DateTime.now().day;
  String retStr = '';
  if (deadline == 0) {
    retStr = '计划今天完成';
  }else if (deadline == 1) {
    retStr = '计划明天完成';
  }else {
    retStr = '离计划的时间还有' + deadline.toString() + '天';
  }

  return retStr;
}