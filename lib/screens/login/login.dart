import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:openemr/utils/customlistloadingshimmer.dart';
import 'package:openemr/utils/rest_ds.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late User user;
  bool _isLoading = false;

  final formKey = GlobalKey<FormState>();
  late String _username, _password, _url;

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _toggleLoadingStatus(bool newLoadingState) {
    setState(() => _isLoading = newLoadingState);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
          backgroundColor: GFColors.LIGHT,
          body: Padding(
            padding: EdgeInsets.only(left: width * 0.1, right: width * 0.1),
            child: Center(
              child: SingleChildScrollView(
                child: _isLoading
                    ? customListLoadingShimmer(
                        context,
                        listLength: 3,
                        loadingMessage: 'Authenticating...',
                      )
                    : Form(
                        key: formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const SizedBox(
                              height: 25,
                            ),
                            Image.asset(
                              'lib/assets/images/gflogo.png',
                              width: width * 0.25,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              child: TextFormField(
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter username';
                                  }
                                  return null;
                                },
                                onSaved: (val) => _username = val!,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Username'),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              child: TextFormField(
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter password';
                                  }
                                  return null;
                                },
                                onSaved: (val) => _password = val!,
                                obscureText: true,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Password'),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              child: TextFormField(
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter url';
                                  }
                                  return null;
                                },
                                onSaved: (val) => _url = val!,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'URL',
                                    hintText: "http://example.com"),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            GFButton(
                              onPressed: () => submit(context),
                              text: 'login',
                              color: GFColors.DARK,
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          )),
    );
  }

  void submit(context) async {
    final prefs = await SharedPreferences.getInstance();
    final form = formKey.currentState;
    RestDatasource api = RestDatasource();
    // if (form!.validate()) {
    //   form.save();
    //   _toggleLoadingStatus(true);
    //   api.login(_username.trim(), _password.trim(), _url).then((User user) {
    //     prefs.setString('token', "${user.tokenType} ${user.accessToken}");
    //     prefs.setString('username', user.username);
    //     prefs.setString('password', user.password);
    //     prefs.setString('baseUrl', user.baseUrl);
    //     _toggleLoadingStatus(false);
    //     Navigator.pop(context);
    //   }).catchError((Object error) {
    //     _toggleLoadingStatus(false);
    //     _showSnackBar(error.toString());
    //   });
  }
}
// }
