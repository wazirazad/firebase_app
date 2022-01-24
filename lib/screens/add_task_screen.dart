import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  var taskName = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            TextField(
              controller: taskName,
              decoration: InputDecoration(
                hintText: 'Add Task'
              ),
            ),
            ElevatedButton(
                onPressed: ()async{
                  var name = taskName.text;
                  if (name.isEmpty) {
                    Fluttertoast.showToast(msg: 'Please provide task name');
                    return;
                  }
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    return;
                  }
                  var databaseRef = FirebaseDatabase.instance.reference();

                  String key =
                      databaseRef.child('tasks').child(user.uid).push().key;

                  try{
                    await databaseRef
                        .child('tasks')
                        .child(user.uid)
                        .child(key)
                        .set({
                      'nodeId' : key,
                      'taskName': name,
                      'dt': DateTime.now().millisecondsSinceEpoch,

                    });
                    Fluttertoast.showToast(msg: 'Task Added');

                  } catch (e ){
                    Fluttertoast.showToast(msg: 'Something went wrong');
                  }
                },
                child: const Text('Save')
            ),
          ],
        ),
      ),
    );
  }
}
