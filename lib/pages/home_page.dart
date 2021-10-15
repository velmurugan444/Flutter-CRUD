import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  TextEditingController _taskController = new TextEditingController();
  TextEditingController _updateTask = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CRUD APP"),
      ),
      body: SingleChildScrollView(
        child: Form(
            key: _formKey,
            child: Column(children: [
              SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _taskController,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        if (!_formKey.currentState.validate()) {
                          return;
                        }
                        _formKey.currentState.save();
                        Map<String, dynamic> _data = {
                          "task": _taskController.text,
                        };
                        FirebaseFirestore.instance
                            .collection("Tasks")
                            .add(_data);
                        _taskController.text = "";
                      },
                    ),
                    hintText: 'Enter task ',
                    hintStyle: TextStyle(
                      letterSpacing: 2,
                      color: Colors.black54,
                    ),
                    fillColor: Colors.white30,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Tasks')
                    .
                    // ignore: deprecated_member_use
                    snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot myPost =
                              snapshot.data.documents[index];
                          return Stack(
                            children: <Widget>[
                              Center(
                                child: Container(
                                  width: double.infinity,
                                  child: Card(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        children: [
                                          Padding(
                                              padding:
                                                  const EdgeInsets.all(20.0),
                                              child: Text(myPost['task'])),
                                          SizedBox(width: 170),
                                          IconButton(
                                            icon: Icon(Icons.update),
                                            onPressed: () {
                                              Alert(
                                                  context: context,
                                                  title: "UPDATE TASK",
                                                  content: Column(
                                                    children: <Widget>[
                                                      TextField(
                                                        controller: _updateTask,
                                                        decoration:
                                                            InputDecoration(
                                                          icon: Icon(Icons
                                                              .account_circle),
                                                          labelText:
                                                              'Enter Task',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  buttons: [
                                                    DialogButton(
                                                      onPressed: () async {
                                                        String updateText =
                                                            _updateTask.text;
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection("Tasks")
                                                            .where("task",
                                                                isEqualTo:
                                                                    myPost[
                                                                        "task"])
                                                            .get()
                                                            .then((snapshot) =>
                                                                snapshot
                                                                    .docs
                                                                    .first
                                                                    .reference
                                                                    .delete());
                                                        Map<String, dynamic>
                                                            _updatedata = {
                                                          "task": updateText,
                                                        };
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection("Tasks")
                                                            .add(_updatedata);
                                                        _updateTask.text = "";
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(
                                                        "UPDATE",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 20),
                                                      ),
                                                    )
                                                  ]).show();
                                            },
                                          ),
                                          SizedBox(width: 10),
                                          IconButton(
                                            icon: Icon(Icons.delete),
                                            onPressed: () {
                                              FirebaseFirestore.instance
                                                  .collection("Tasks")
                                                  .where("task",
                                                      isEqualTo: myPost['task'])
                                                  .get()
                                                  .then((snapshot) => snapshot
                                                      .docs.first.reference
                                                      .delete());
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 70)
                            ],
                          );
                        });
                  }
                },
              ),
            ])),
      ),
    );
  }
}
