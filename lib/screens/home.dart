import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
// import 'package:openemr/screens/codescanner/codescanner.dart';
import 'package:openemr/screens/login/login2.dart';
import 'package:openemr/screens/medicine/medicine_recognition_ML_Kit.dart';
import 'package:openemr/screens/patientList/patient_list.dart';
import 'package:openemr/screens/ppg/heart_rate.dart';
import 'package:openemr/screens/telehealth/telehealth.dart';
import 'package:openemr/utils/rest_ds.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/drawer/drawer.dart';
import 'login/login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final userRef = FirebaseFirestore.instance.collection('username');
  final FirebaseAuth auth = FirebaseAuth.instance;

  final firebaseFlag = false;

  List gfComponents = [
    {
      'icon': CupertinoIcons.heart_solid,
      'title': 'PPG',
      'route': const PPG(),
    },
    {
      'icon': Icons.video_call,
      'title': 'Telehealth',
      'authentication': "firebase",
      'failRoute': const LoginFirebaseScreen(),
      'route': const Telehealth(),
    },
    {
      'icon': Icons.people,
      'title': 'Patient List',
      // 'route': const PatientListPage(),
      'authentication': "webapp",
      'failRoute': const LoginScreen(),
    },
    {
      'icon': Icons.translate,
      'title': 'Medicine Recognition',
      'route': const MedicineRecognitionMLKit(),
    },
    {
      'icon': Icons.scanner,
      'title': 'Code scanner',
      // 'route': const CodeScanner(),
    },
  ];

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        drawer: const DrawerPage(),
        appBar: AppBar(
          backgroundColor: GFColors.DARK,
          title: Image.asset(
            'lib/assets/icons/gflogo.png',
            width: 150,
          ),
          centerTitle: true,
        ),
        body: ListView(
          physics: const ScrollPhysics(),
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(
                left: 15,
                bottom: 20,
                top: 20,
                right: 15,
              ),
              // child: GridView.builder(
              //   scrollDirection: Axis.vertical,
              //   shrinkWrap: true,
              //   physics: const ScrollPhysics(),
              //   itemCount: gfComponents.length,
              //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              //       crossAxisCount: 2,
              //       crossAxisSpacing: 20,
              //       mainAxisSpacing: 20),
              //   itemBuilder: (BuildContext context, int index) =>
              //       buildSquareTile(
              //     gfComponents[index]['title'],
              //     gfComponents[index]['icon'],
              //     gfComponents[index]['route'],
              //     gfComponents[index]['authentication'],
              //     gfComponents[index]['failRoute'],
              //     gfComponents[index]['disabled'] ?? false,
              //   ),
              // ),
            ),
          ],
        ),
      );

//   Widget buildSquareTile(
//     String title,
//     IconData icon,
//     Widget route,
//     String auth,
//     Widget failRoute,
//     bool disabled,
//   ) =>
//       InkWell(
//         onTap: !disabled
//             ? () async {
//                 String loggedUserId = '';
//                 if (auth == "webapp") {
//                   final prefs = await SharedPreferences.getInstance();
//                   var username = prefs.getString('username');
//                   var password = prefs.getString('password');
//                   var url = prefs.getString('baseUrl');
//                   RestDatasource api = RestDatasource();
//                   api.login(username!, password!, url!).then((firebaseUser)
//                    {
//                     prefs.setString('token',
//                         "${firebaseUser.tokenType} ${firebaseUser.accessToken}");
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (BuildContext context) => route),
//                     );
//                   }).catchError((Object error) {
//                     MaterialPageRoute(
//                         builder: (BuildContext context) => failRoute);
//                   });
//                 } else if (auth == "firebase") {
//                   FirebaseAuth auth = FirebaseAuth.instance;
//                   User? user = auth.currentUser;
//                   bool isEmailValid =
//                       EmailValidator.validate(user?.email ?? '');
//                   if (user != null && isEmailValid) {
//                     SharedPreferences prefs =
//                         await SharedPreferences.getInstance();
//                     loggedUserId = prefs.getString('loggedUserId') ?? '';
//                     MaterialPageRoute(builder: (context) => route);
//                   }
//                   if (loggedUserId.isNotEmpty) {
//                     DocumentSnapshot documentSnapshot =
//                         await userRef.doc(loggedUserId).get();
//                     if (documentSnapshot.exists) {
//                       MaterialPageRoute(
//                           builder: (BuildContext context) => route);
//                     } else {
//                       MaterialPageRoute(
//                           builder: (BuildContext context) => failRoute);
//                     }
//                   } else {
//                     MaterialPageRoute(
//                         builder: (BuildContext context) => failRoute);
//                   }
//                 } else {
//                   _showSnackBar("Check readme to enable firebase");
//                 }
//               }
//             : null,
//         child: Container(
//           decoration: BoxDecoration(
//             color: !disabled ? const Color(0xFF333333) : Colors.grey[500],
//             borderRadius: const BorderRadius.all(Radius.circular(7)),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.61),
//                 blurRadius: 6,
//                 spreadRadius: 0,
//               ),
//             ],
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: <Widget>[
//               Icon(
//                 icon,
//                 color: !disabled
//                     ? GFColors.SUCCESS
//                     : Colors.white.withOpacity(0.7),
//                 size: 30,
//               ),
// //            Icon((icon),),
//               Text(title,
//                   style: const TextStyle(color: GFColors.WHITE, fontSize: 20),
//                   textAlign: TextAlign.center)
//             ],
//           ),
//         ),
//       );
// }
}
