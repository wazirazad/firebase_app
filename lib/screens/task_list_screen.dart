import 'package:firebase_account/models/task_model.dart';
import 'package:firebase_account/screens/profile_screen.dart';
import 'package:firebase_account/screens/sign_in_screen.dart';
import 'package:firebase_account/screens/update_task_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import 'add_task_screen.dart';
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  User? user;
  DatabaseReference? taskRef;

  @override
  void initState() {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      taskRef =
          FirebaseDatabase.instance.reference().child('tasks').child(user!.uid);
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task List'),
        actions: [
          IconButton(onPressed: (){
            //here profile screen
            Navigator.of(context).push(MaterialPageRoute(builder: (ctx){
              return const ProfileScreen();
            }));
          },
              icon: const Icon(Icons.person)),
          IconButton(onPressed: ()async{
            await FirebaseAuth.instance.signOut();
            Navigator.of(context)
                .pushReplacement(MaterialPageRoute(builder: (context) {
              return const SignInScreen();
            }));
          }, icon: const Icon(Icons.logout)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx){
            return const AddTaskScreen();
          }));
        },
        child: Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: taskRef != null ? taskRef!.onValue : null,
        builder: (context, snap) {
          if (snap.hasData && !snap.hasError) {
            var event = snap.data as Event;
            print(event.toString());
            var snshot = event.snapshot.value;

            if( snshot == null ){
              return Center(child: Text('No tasks yet'));
            }

            Map<String, dynamic> map = Map<String, dynamic>.from(snshot);
            print(map.toString());
            var tasks = <TaskModel>[];

            for (var taskMap in map.values) {
              tasks.add(TaskModel.fromMap(Map<String, dynamic>.from(taskMap)));
            }
            print(tasks.length);

            return ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  TaskModel taskModel = tasks[index];

                  return Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0,top: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.amber,
                    ),
                    child: Row(children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(taskModel.taskName),
                            Text(getHumanReadableDate(taskModel.dt))
                          ],
                        ),
                      ),
                      Container(
                        child: Column(
                          children: [
                            IconButton(
                                onPressed: () async {
                                  if (taskRef != null) {
                                    // show alertdialog
                                    showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (ctx) {
                                          return AlertDialog(
                                            title: const Text('Confirmation'),
                                            content: const Text(
                                                'Are you sure to delete ?'),
                                            actions: [
                                              TextButton(onPressed: () {
                                                Navigator.of(ctx).pop();
                                              }, child: const Text('No')),


                                              TextButton(onPressed: () async {
                                                try {
                                                  await taskRef!
                                                      .child(taskModel.nodeId).remove();

                                                }
                                                catch ( e ){
                                                  print(e.toString());
                                                  Fluttertoast.showToast(msg: 'failed');
                                                }

                                                Navigator.of(ctx).pop();

                                              }, child: const Text('Yes')),
                                            ],
                                          );
                                        });
                                  }
                                },
                                icon: const Icon(Icons.delete)),
                            IconButton(
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                    return UpdateTaskScreen(taskModel: taskModel);
                                  }));

                                }, icon: const Icon(Icons.edit)),
                          ],
                        ),
                      )
                    ]),
                  );
                });
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
  String getHumanReadableDate(int dt) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(dt);
    return DateFormat('dd/MM/yyyy hh:mm').format(dateTime);
  }
}
