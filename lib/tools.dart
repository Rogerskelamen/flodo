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
  // 已知条件
  // 1. 首先DateTime.now()是当前*时刻*
  // 2. 如果用date.difference()获取得是秒数
  // 3. 如果是今天定的目标，inDays之后一定等于0
  // 4. 其实inDays就是取整一个范围，即(-1, 1)全开区间全部取整为0
  // 5. 那么取整为0就有两种可能，
  // 第一种：（-1, 0)，这是已经超过了我们预定的时间，但是还没有超过一天，
  // 假如我们预定时间是3/6正午12:00，那么此时的时间必须是不超过3/7正午12:00才算是第一种
  // 所以说day相减只有可能是0或者-1，如果是0的话必定是3/7(0:00~12:00)
  // 第二种：（0, 1)，这是还没有到我们预定的时间，但是预定时间在一天之内，
  // 假如我们预定时间是3/8正午12:00，那么此时的时间必须是超过3/7正午12:00才算是第一种
  // 所以说day相减只有可能是0或者1，如果是0的话必定是3/7(12:00~24:00)

  // judge if the plan day has been passed
  int dayInterval = date.day - DateTime.now().day;
  if (date.isBefore(DateTime.now()) && dayInterval < 0) {
    return '你应该已经完成它了';
  }
  Duration passTime = date.difference(DateTime.now());
  String retStr = '';
  if (passTime.inDays == 0 && dayInterval == 0) {
    retStr = '计划今天完成';
  }else if (passTime.inDays == 0 && dayInterval == 1) {
    retStr = '计划明天完成';
  }else {
    retStr = '离计划的时间还有' + (passTime.inDays + 1).toString() + '天';
  }

  return retStr;
}