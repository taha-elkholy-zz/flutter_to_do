import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:to_do_app/auth/login.dart';
import 'package:to_do_app/todo/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  var _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _hasError = false;

  String _errorMessage;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Register New Account'),
      ),
      body: (_isLoading) ? _loading(context) : _form(context),
    );
  }

  Widget _form(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(36),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(hintText: 'Email'),
                validator: (value) {
                  if (value.isEmpty || !value.contains('@')) {
                    return 'Email is required';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(hintText: 'Password'),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length != 6) {
                    return 'Password is at least 6 digits';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(hintText: 'Confirm Password'),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Confirm Password is required';
                  }
                  if (value != _passwordController.text) {
                    return 'Confirm Password not match';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 48,
              ),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  child: Text('Register'),
                  onPressed: _onRegisterClicked,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  Text('Do you have account?'),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => LoginScreen()));
                      },
                      child: Text('Login'))
                ],
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

  Widget _loading(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  void _onRegisterClicked() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: _emailController.text,
                password: _passwordController.text)
            .then((value) => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => HomeScreen())));
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          setState(() {
            _hasError = true;
            _isLoading = false;
            _errorMessage = 'The password provided is too weak.';
          });
          print('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          setState(() {
            _hasError = true;
            _isLoading = false;
            _errorMessage = 'The account already exists for that email.';
          });
          print('The account already exists for that email.');
        }
      } catch (e) {
        print(e);
      }
      UserCredential user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _emailController.text, password: _passwordController.text)
          .whenComplete(() => setState(() {
                _isLoading = false;
              }));

      if (user == null) {
        print('Error while creating user');
      } else {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomeScreen()));
      }
    }
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
