import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewToDo extends StatefulWidget {
  const NewToDo({Key key}) : super(key: key);

  @override
  _NewToDoState createState() => _NewToDoState();
}

class _NewToDoState extends State<NewToDo> {
  TextEditingController _toDoController = TextEditingController();
  var _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  CollectionReference _toDos = FirebaseFirestore.instance.collection('todos');

  String _errorMessage;
  bool _hasError = false;

  @override
  void dispose() {
    super.dispose();
    _toDoController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('New ToDo'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: _saveToDo,
      ),
      body: (_isLoading) ? _loading(context) : _form(context),
    );
  }

  void _saveToDo() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });
      await _toDos
          .doc(FirebaseAuth.instance.currentUser.uid)
          .collection('user_todos')
          .doc()
          .set({
            'body': _toDoController.text,
            'done': false, // false in the first
            //'user_id': FirebaseAuth.instance.currentUser.uid
          })
          .then(
              (value) => Navigator.of(context).pop()) // finish and return back
          .catchError((error) {
            setState(() {
              _errorMessage = 'Something went wrong';
              _hasError = true;
              _isLoading = false;
            });
            print(error);
          })
          .timeout(Duration(seconds: 40), onTimeout: () {
            setState(() {
              _isLoading = false;
              _errorMessage = 'Timeout, try again';
              _hasError = true;
            });
          });
    }
  }

  Widget _loading(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  _form(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _toDoController,
                decoration: InputDecoration(hintText: ' New ToDo'),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'You can not save empty text';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 48,
              ),
              (_hasError) ? _showErrorMessage() : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _showErrorMessage() {
    return Container(
      child: Text(
        _errorMessage,
        style: TextStyle(color: Colors.red),
      ),
    );
  }
}
