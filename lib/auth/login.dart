import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:to_do_app/auth/register.dart';
import 'package:to_do_app/todo/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  var _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Login'),
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
                  if (value.isEmpty) {
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
                  return null;
                },
              ),
              SizedBox(
                height: 48,
              ),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  child: Text('Login'),
                  onPressed: _onLoginClicked,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  Text('Do not have account?'),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => RegisterScreen()));
                      },
                      child: Text('Register'))
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

  void _onLoginClicked() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: _emailController.text,
                password: _passwordController.text)
            .then((value) => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => HomeScreen())))
            .timeout(
                Duration(
                  seconds: 30,
                ), onTimeout: () {
          setState(() {
            _hasError = true;
            _isLoading = false;
            _errorMessage = 'Something went wrong';
          });
        });
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          setState(() {
            _hasError = true;
            _isLoading = false;
            _errorMessage = 'No user found for that email.';
          });
          print('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          setState(() {
            _hasError = true;
            _isLoading = false;
            _errorMessage = 'Wrong password provided for that user.';
          });
          print('Wrong password provided for that user.');
        }
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
