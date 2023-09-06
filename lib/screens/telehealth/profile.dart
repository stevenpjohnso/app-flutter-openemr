import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:openemr/screens/telehealth/telehealth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseProfileScreen extends StatefulWidget {
  //user's current display name
  final String dispName;
  const FirebaseProfileScreen({required Key key, required this.dispName})
      : super(key: key);
  @override
  _FirebaseProfileScreenState createState() => _FirebaseProfileScreenState();
}

class _FirebaseProfileScreenState extends State<FirebaseProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _store = FirebaseFirestore.instance;
  late User user;

  final formKey = GlobalKey<FormState>();
  late String _name;

  //decides when to active/inactive spinner indicator
  bool showSpinner = false;

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
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
      // child: Scaffold(
      //   backgroundColor: GFColors.LIGHT,
      //   body:
      //  ModalProgressHUD(
      //       color: Colors.blueAccent,
      //       inAsyncCall: showSpinner,
      //       child: Padding(
      //         padding: EdgeInsets.only(left: width * 0.1, right: width * 0.1),
      //         child: Center(
      //           child: SingleChildScrollView(
      //             child: Form(
      //               key: formKey,
      //               child: Column(
      //                 mainAxisAlignment: MainAxisAlignment.center,
      //                 crossAxisAlignment: CrossAxisAlignment.center,
      //                 children: <Widget>[
      //                   const SizedBox(
      //                     height: 25,
      //                   ),
      //                   const SizedBox(
      //                     height: 20,
      //                   ),
      //                   SizedBox(
      //                     child: TextFormField(
      //                       //set initial value as the dispName
      //                       initialValue: widget.dispName,
      //                       validator: (value) {
      //                         if (value!.isEmpty) {
      //                           return 'Display name can\'t be blank';
      //                         }
      //                         return null;
      //                       },
      //                       onSaved: (val) => _name = val!,
      //                       decoration: const InputDecoration(
      //                           border: OutlineInputBorder(),
      //                           labelText: 'Display name'),
      //                     ),
      //                   ),
      //                   const SizedBox(
      //                     height: 20,
      //                   ),
      //                   GFButton(
      //                     onPressed: () => updateProfile(context),
      //                     text: 'Update',
      //                     color: GFColors.DARK,
      //                   ),
      //                 ],
      //               ),
      //             ),
      //           ),
      //         ),
      //       ),
      //     ),
      //   ),
      // );
      // }

//   void updateProfile(context) async {
//     //start showing the spinner
//     setState(() {
//       showSpinner = true;
//     });
//     User user;
//     String errorMessage;
//     final form = formKey.currentState;
//     if (form!.validate()) {
//       form.save();
//       try {
//         user = await _auth.currentUser();
//         UserUpdateInfo updateInfo = UserUpdateInfo();
//         updateInfo.displayName = _name;
//         await user.updateProfile(updateInfo);
//       } catch (error) {
//         //stop showing the spinner
//         setState(() {
//           showSpinner = false;
//         });
//         switch (error.code) {
//           case "ERROR_USER_DISABLED":
//             errorMessage = "Your acount has been disabled";
//             break;
//           case "ERROR_USER_NOT_FOUND":
//             errorMessage = "Account not found";
//             break;
//           default:
//             errorMessage = error.code ?? "An undefined Error happened.";
//         }
//       }
//     }
//     //stop showing the spinner
//     setState(() {
//       showSpinner = false;
//     });
//     _showSnackBar(errorMessage);
//     return null;
//     await _store
//         .collection('username')
//         .document(user.uid)
//         .updateData({"name": _name});
//     Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(builder: (context) => const Telehealth()),
//         (route) => false);
//     //stop showing the spinner
//     setState(() {
//       showSpinner = false;
//     });
//   }
// }
    );
  }
}
