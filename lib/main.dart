import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'TablesInit.dart';
import 'DBUtil.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo',
      theme: ThemeData(
        primarySwatch:Colors.blue,
      ),
      home: MyHomePage(title:'数据操作'),
    );
  }
}

class MyHomePage extends StatefulWidget{
  MyHomePage({Key key,this.title}) :super(key:key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
  final String title;

}

class _MyHomePageState extends State<MyHomePage>{
  var dataList = "";
  DBUtil dbUtil = null;
 @override
  void initState() {
    super.initState();
    initDB();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("数据操作"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: (){

              },
            )
          ],
        ),
        body: new Container(
          alignment: Alignment.center,
          child:Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                // SizedBox(width: 400),
                  RaisedButton.icon(
                      icon: Icon(Icons.search),
                      label: Text('查询'),
                      color: Colors.blue,
                      textColor: Colors.white,
                      // onPressed: null,
                      onPressed: () {
                        print("查询数据");
                        queryData();
                        
                      }),
                  SizedBox(width: 10),
                  RaisedButton(
                    padding: new EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                    child: Text('插入'),
                    color: Colors.blue,
                    textColor: Colors.white,
                    onPressed: () {
                      print("插入");
                      insertData();
                    },
                  ),
                  SizedBox(width: 10),
                  RaisedButton(
                    child: Text('清除'),
                    color: Colors.blue,
                    textColor: Colors.white,
                    onPressed: () {
                      print("清除");
                      delete();
                    },
                  ),
                  SizedBox(width: 10),
                  RaisedButton(
                    child: Text('修改'),
                    color: Colors.blue,
                    textColor: Colors.white,
                    elevation: 20,
                    onPressed: () {
                      print("修改");
                      update();
                    },
                  ),
                  
                ],
              ),Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                // SizedBox(width: 400),
                  RaisedButton.icon(
                      icon: Icon(Icons.add_box),
                      label: Text('批量插入'),
                      color: Colors.blue,
                      textColor: Colors.white,
                      // onPressed: null,
                      onPressed: () {
                        print("批量插入");
                        batchDispose();
                        
                      }),
                  SizedBox(width: 10),
                  RaisedButton(
                    padding: new EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                    child: Text('事务控制'),
                    color: Colors.blue,
                    textColor: Colors.white,
                    onPressed: () {
                      print("事务控制");
                      transaction();
                    },
                  ),
                  SizedBox(width: 10),
                  RaisedButton(
                    child: Text(''),
                    color: Colors.blue,
                    textColor: Colors.white,
                    onPressed: () {
                      print("");
                      delete();
                    },
                  ),
                ],
              ),
              new Container(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "数据:",
                  ),
                  Text(
                    dataList,
                  )
          ],
        ),
              )
            ],
        ),
        ),
        
        );
  }
  void initDB() async {
    TablesInit tables = TablesInit();
    tables.init();
    dbUtil = new DBUtil();
  }
  void insertData() async {
    await dbUtil.open();
    Map<String,Object> par = Map<String,Object>();
    par['uid'] = Random().nextInt(10);
    par['fuid'] = Random().nextInt(10);
    par['type'] = Random().nextInt(2);
    int flag = await dbUtil.insertByHelper('relation', par);
    //int flag = await dbUtil.insert('INSERT INTO relation(uid, fuid, type) VALUES("111111", "2222222", 1)');
    print('flag:$flag');
    await dbUtil.close();
    queryData();
  }

  void delete() async{
    await dbUtil.open();
    dbUtil.delete('DELETE FROM relation', null);
    //dbUtil.deleteByHelper('relation','uid=? and fuid=?',[1,6]);
    await dbUtil.close();
    queryData();
  }

  void update() async{
    await dbUtil.open();
    //dbUtil.update('UPDATE relation SET fuid = ?, type = ? WHERE uid = ?', [Random().nextInt(10),Random().nextInt(10),5]);
    Map<String,Object> par = Map<String,Object>();
    par['fuid'] = Random().nextInt(10);
    dbUtil.updateByHelper('relation', par, 'type=? and uid=?', [0,5]);
    await dbUtil.close();
    queryData();
  }

  void queryData() async{
    await dbUtil.open();
    List<Map> data = await dbUtil.queryList("SELECT * FROM relation");
    //List<Map> data = await dbUtil.queryListByHelper('relation', ['id','uid','fuid','type'], 'uid=?', [5]);
    print('data：$data');
    String showdata = "";
    if(data == null){
      showdata = "";
    }else{
      showdata = data.toString();
    }
    setState(() {
      dataList = showdata;
    });
    await dbUtil.close();
  }

  //批量处理
  void batchDispose() async{
    await dbUtil.open();
    Batch batch = await dbUtil.getBatch();
    Map<String,Object> par = Map<String,Object>();
    for(int n=0; n<5;n++){
        par['uid'] = Random().nextInt(10);
        par['fuid'] = Random().nextInt(10);
        par['type'] = Random().nextInt(2);
        batch.insert('relation', par);
    }
     List<Object> results = await batch.commit(); 
     print('results:$results');//返回的是id
                            
    await dbUtil.close();
    queryData();
  }

  //事务控制
  void transaction() async{
      await dbUtil.open();
      try {
        await dbUtil.transaction((txn) async {
           Map<String,Object> par = Map<String,Object>();
           par['uid'] = Random().nextInt(10); par['fuid'] = Random().nextInt(10);
           par['type'] = Random().nextInt(2); par['id'] = 1;
           var a = await txn.insert('relation', par);
           var b = await txn.insert('relation', par);
      });
      } catch (e) {
        print('sql异常:$e');
      }
      await dbUtil.close();
      queryData();
  }
}

