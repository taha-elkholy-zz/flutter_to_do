import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:to_do_app/ui/auth/login.dart';
import 'package:to_do_app/ui/newtodo.dart';
import 'package:to_do_app/utilities/views_utilities.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userID;
  bool _hasError = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    setState(() {
      _userID = FirebaseAuth.instance.currentUser.uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Home'),
      ),
      body: _content(context),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => NewToDo()));
        },
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.teal.shade300,
                child: Center(child: Text('Header')),
              ),
            ),
            ListTile(
              title: Text('Logout'),
              trailing: Icon(Icons.exit_to_app),
              onTap: _logout,
            )
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('todos')
            .doc(_userID)
            .collection('user_todos')
            .orderBy('done', descending: false)
            .snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Center(
                child: Text(
                  'Connection Error',
                  style: ViewsUtilities.errorStyle,
                ),
              );
              break;
            case ConnectionState.waiting:
              return ViewsUtilities.loading;
              break;
            case ConnectionState.active:
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error in returned data',
                    style: ViewsUtilities.errorStyle,
                  ),
                );
              } else {
                if (snapshot.hasData) {
                  return _drawScreen(context, snapshot.data);
                } else {
                  return Center(
                    child: Text(
                      'No Data To show',
                      style: ViewsUtilities.errorStyle,
                    ),
                  );
                }
              }
              break;
          }
          return Container(width: 0.0, height: 0.0);
        },
      ),
    );
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut().then((_) {
      Navigator.of(context).pop(); // close drawer
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()));
    }).catchError((error) {
      return Center(
        child: Text(
          error,
          style: ViewsUtilities.errorStyle,
        ),
      );
    });
  }

  Widget _drawScreen(BuildContext context, QuerySnapshot data) {
    return ListView.builder(
        itemCount: data.docs.length,
        itemBuilder: (context, position) {
          return Card(
            child: ListTile(
              title: Text(
                data.docs[position]['body'],
                style: TextStyle(
                  decoration: data.docs[position]['done']
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              trailing: IconButton(
                  icon: Icon(
                    Icons.delete_rounded,
                    color: Colors.red.shade400,
                  ),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('todos')
                        .doc(_userID)
                        .collection('user_todos')
                        .doc(data.docs[position].id)
                        .delete();
                  }),
              leading: IconButton(
                  icon: Icon(
                    Icons.check_box,
                    color: data.docs[position]['done']
                        ? Colors.teal
                        : Colors.grey.shade300,
                  ),
                  onPressed: () async {
                    if (!data.docs[position]['done']) {
                      await FirebaseFirestore.instance
                          .collection('todos')
                          .doc(_userID)
                          .collection('user_todos')
                          .doc(data.docs[position].id)
                          .update({'done': true});
                    }
                  }),
            ),
          );
        });
  }
}
