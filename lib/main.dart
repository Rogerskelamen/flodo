import 'dart:ui';

// import theme
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// import data store
import 'package:shared_preferences/shared_preferences.dart';

// import entity
import './todo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flodo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData.dark(),
      home: const MyHomePage(title: 'Todo List'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  // 设置待办名称缓存
  String _itemName = '';
  DateTime _date = DateTime.now();

  List<TodoList> _todos = [];

  // 初始化Widget
  @override
  void initState() {
    super.initState();
    // 注册应用生命周期监听
    _reloadData();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // 移除生命周期监听
    _storeData();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    // print(':didChangeAppLifecycleState:$state');
    switch (state) {
      // 处于这种状态的应用程序应该假设他们可能在任何时候暂停
      case AppLifecycleState.inactive:  // 开始对app进行操作（任何操作）
        _storeData();
        break;
      case AppLifecycleState.resumed: // 从后台切前台，界面可见
        // print('resumed');
        break;
      case AppLifecycleState.paused: // 界面不可见，后台
        // print('paused');
        break;
      case AppLifecycleState.detached: // APP 结束时调用
        // print('detached');
        break;
    }
  }

  // 存储数据
  void _storeData() async {
    // 数据存储对象
    final prefs = await SharedPreferences.getInstance();
    List<String> todoNames = [];
    List<String> todoDates = [];
    // 将当前的所有待办的名字和时间各存入一个缓冲中
    for (var i = 0; i < _todos.length; i++) {
      if (! _todos[i].isChecked) {
        todoNames.add(_todos[i].itemName);
        todoDates.add(_todos[i].date.toString());
      }
    }
    // 存入数据
    prefs.setStringList('todoNames', todoNames);
    prefs.setStringList('todoDates', todoDates);
  }

  // 读取数据
  void _reloadData() async {
    final prefs = await SharedPreferences.getInstance();
    // 获取数据
    List<String>? todoNames = prefs.getStringList('todoNames');
    List<String>? todoDates = prefs.getStringList('todoDates');
    // 将数据归位到待办事项列表中
    setState(() {
      // 直接将_todos置空
      _todos = [];
      if (todoNames != null && todoDates != null) {
        for (var i = 0; i < todoNames.length; i++) {
          _todos.add(
            TodoList(
              itemName: todoNames[i],
              date: DateTime.parse(todoDates[i]),
              isChecked: false
            )
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontSize: 24.0),),
        centerTitle: true,
      ),
      body: Center(
        child: ListView.builder(
          itemCount: _todos.length,
          itemExtent: 92.0,
          itemBuilder: (BuildContext context, int index) {
            // every todo list item
            return Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.computeLuminance() < 0.5 ? Colors.white : Colors.black38,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 0),
                    blurRadius: 5.0
                  )
                ]
              ),
              child: ListTile(
                style: ListTileStyle.drawer,
                leading: const Icon(Icons.domain_verification_sharp, size: 40,),
                // 待办事项名
                title: Text(_todos[index].itemName, style: const TextStyle(fontSize: 20),),
                subtitle: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 5.0),
                      child: const Icon(Icons.access_time, size: 16),
                    ),
                    // 显示时间
                    Text(_todos[index].date.day.toString() + '-' + _todos[index]
                      .date.month.toString() + '-' + _todos[index].date.year
                      .toString() + ' ' + getWeek(_todos[index].date.weekday),
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    )
                  ],
                ),
                // 尾部单选框
                trailing: Checkbox(
                  // 设置为每个待办的状态
                  value: _todos[index].isChecked,
                  activeColor: Colors.blue,
                  onChanged: (value) {
                    setState(() {
                      _todos[index].isChecked = value!;
                    });
                  },
                ),
              )
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 点击弹出之后初始化所有可变数据
          _date = DateTime.now();
          _itemName = '';

          showCupertinoModalPopup(
            // 取消点击任意键之后可以退出
            barrierDismissible: false,
            context: context,
            // 设置背景模糊
            filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
            builder: (context) {
              return Center(
                child: Column(
                  children: [
                    // two button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 取消按钮
                        Container(
                          margin: const EdgeInsets.only(left: 10.0, top: 50.0),
                          child: CupertinoButton(
                            child: const Text('取消', style: TextStyle(color: Colors.lightBlueAccent),),
                            onPressed: () {
                              Navigator.of(context).pop();
                            }
                          ),
                        ),
                        // 确定按钮
                        Container(
                          margin: const EdgeInsets.only(right: 10.0, top: 50.0),
                          child: CupertinoButton(
                            child: const Text('确定', style: TextStyle(color: Colors.lightBlueAccent),),
                            onPressed: () {
                              if (_itemName.isEmpty) {
                                // 如果为空直接返回
                                return;
                              }
                              setState(() {
                                // 遍历所有待办查找那个待办正好在当前待办时间的后面
                                for (var i = 0; i < _todos.length; i++) {
                                  if (_todos[i].date.isAfter(_date)) {
                                    _todos.insert(i,
                                      TodoList(
                                        itemName: _itemName,
                                        date: _date,
                                        isChecked: false
                                      )
                                    );
                                    // 插入之后直接return退出
                                    return;
                                  }
                                }
                                // 如果还没有退出，说明当前的待办时间是最后的，直接加上
                                _todos.add(TodoList(itemName: _itemName, date: _date, isChecked: false));
                              });
                              Navigator.of(context).pop();
                            }
                          ),
                        )
                      ],
                    ),
                    // Text Field
                    Container(
                      height: 60.0,
                      padding: const EdgeInsets.only(left: 20.0),
                      child: CupertinoTextField(
                        // 自动呼出键盘
                        autofocus: true,
                        // 设置输入框为透明
                        decoration: const BoxDecoration(
                          color: Colors.transparent
                        ),
                        cursorHeight: 32.0,
                        style: TextStyle(
                          fontSize: 25.0,
                          // 字体色随主题色渐变
                          color: Theme.of(context).colorScheme.secondary.computeLuminance() > 0.5 ? Colors.white : Colors.black,
                        ),
                        // 接收输入框中的文字
                        onChanged: (value) {
                          _itemName = value;
                        },
                      )
                    ),
                    // Date Picker
                    SizedBox(
                      height: 300.0,
                      child: CupertinoTheme(
                        data: const CupertinoThemeData(
                          textTheme: CupertinoTextThemeData(
                            dateTimePickerTextStyle: TextStyle(
                              fontSize: 22.0
                            )
                          )
                        ),
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.date,
                          dateOrder: DatePickerDateOrder.ymd,
                          minimumDate: DateTime.now(),
                          initialDateTime: DateTime.now(),
                          onDateTimeChanged: (value) {
                            _date = value;
                          },
                        ),
                      )
                    )
                  ],
                ),
              );
            },
          );
        },
        tooltip: '添加待办事项',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
