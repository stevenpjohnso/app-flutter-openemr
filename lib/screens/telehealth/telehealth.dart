import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:openemr/screens/telehealth/chat.dart';
import 'package:openemr/screens/telehealth/local_widgets/profile_shimmer.dart';
import 'package:openemr/screens/telehealth/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:openemr/screens/telehealth/signaling.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:openemr/utils/system_padding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Telehealth extends StatefulWidget {
  const Telehealth({super.key});

  @override
  _TelehealthState createState() => _TelehealthState();
}

class _TelehealthState extends State<Telehealth>
    with SingleTickerProviderStateMixin {
  late Signaling _signaling;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _store = FirebaseFirestore.instance;
  bool _inCalling = false;
  String serverIP = "";
  late List<dynamic> _peers;
  late User user;
  late String userId;
  late List directory;
  late List activeChats;
  late TabController tabController;

  final GoogleSignIn googleSignIn = GoogleSignIn();

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  void initState() {
    super.initState();
    getInfo();
    tabController = TabController(length: 4, vsync: this);
  }

  initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<void> _signOut() async {
    await googleSignIn.signOut();
    await _auth.signOut();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('loggedUserId');
  }

  @override
  deactivate() {
    super.deactivate();
    if (!(serverIP == "")) {
      _localRenderer.dispose();
      _remoteRenderer.dispose();
    }
    _signaling.close();
  }

  void _connect() async {
    // _signaling = Signaling(serverIP, userId)..connect(user.displayName);

    // _signaling.onStateChange = (SignalingState state) {
    //   switch (state) {
    //     case SignalingState.CallStateNew:
    //       setState(() {
    //         _inCalling = true;
    //       });
    //       break;
    //     case SignalingState.CallStateBye:
    //       setState(() {
    //         _localRenderer.srcObject = null;
    //         _remoteRenderer.srcObject = null;
    //         _inCalling = false;
    //       });
    //       break;
    //     case SignalingState.CallStateInvite:
    //     case SignalingState.CallStateConnected:
    //     case SignalingState.CallStateRinging:
    //     case SignalingState.ConnectionClosed:
    //     case SignalingState.ConnectionError:
    //     case SignalingState.ConnectionOpen:
    //       break;
    //   }
    // };

    _signaling.onPeersUpdate = ((event) {
      setState(() {
        _peers = event['peers'];
      });
    });

    _signaling.onLocalStream = ((stream) {
      _localRenderer.srcObject = stream;
    });

    _signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
    });

    _signaling.onRemoveRemoteStream = ((stream) {
      _remoteRenderer.srcObject = null;
    });
  }

  getInfo() async {
    directory = [];
    activeChats = [];
    userId = "";
    // user = await _auth.currentUser();
    final prefs = await SharedPreferences.getInstance();
    serverIP = prefs.getString("webrtcIP") ?? "";
    // QuerySnapshot docs = await _store.collection('username').getDocuments();
    // docs.documents.forEach((element) {
    //   if (element.documentID == user.uid) {
    //     userId = element["id"];
    //   } else {
    //     directory.add(element.data);
    //   }
    // });

    // QuerySnapshot fetchedChats = await _store
    //     .collection('chats')
    //     .where(userId, isEqualTo: true)
    //     .getDocuments();
    // fetchedChats.documents.forEach((element)
    //  {
    //   var x = element.data;
    //   element.data["names"].forEach((key, value) {
    //     if (key != userId) {
    //       x["targetName"] = value;
    //     }
    //   });
    //   x["documentId"] = element.documentID;
    //   activeChats.add(x);
    // });

    setState(() {
      serverIP = serverIP;
      activeChats = activeChats;
      directory = directory;
      user = user;
      userId = userId;
    });
    if (serverIP != "") {
      _connect();
      initRenderers();
    }
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  String tempIp = "";

  startChat(context, targetUser) async {
    var messagesId = "";
    var chatDocumentId = "";
    QuerySnapshot chats = await _store
        .collection('chats')
        .where(userId, isEqualTo: true)
        .where(targetUser["id"], isEqualTo: true)
        .snapshots()
        .first;

    //   if (chats.documents.isEmpty) {
    //     DocumentReference mesref = await _store.collection('messages').add({});
    //     DocumentReference chatref = await _store.collection('chats').add({
    //       userId: true,
    //       targetUser["id"]: true,
    //       "messageId": mesref.documentID,
    //       "names": {
    //         userId: user.displayName,
    //         targetUser["id"]: targetUser["name"]
    //       }
    //     });
    //     messagesId = mesref.documentID;
    //     chatDocumentId = chatref.documentID;
    //   } else {
    //     messagesId = chats.documents[0].data["messageId"];
    //     chatDocumentId = chats.documents[0].documentID;
    //   }
    //   if (messagesId != "") {
    //     Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //           builder: (BuildContext context) => ChatScreen(
    //                 messagesId: messagesId,
    //                 heading: targetUser["name"],
    //                 userId: userId,
    //                 userName: user.displayName,
    //                 chatDocumentId: chatDocumentId,
    //               )),
    //     );
    //   } else {
    //     _showSnackBar("Chat id can't be generated");
    //   }
    // }

    _hangUp() {
      _signaling.bye();
    }

    _switchCamera() {
      _signaling.switchCamera();
    }

    _invitePeer(context, peerId) async {
      print("hello");
      if (peerId != userId) {
        _signaling.invite(peerId, 'video');
      }
    }

    // _updateServerIp() async {
    //   await showDialog<String>(
    //     context: context,
    //     builder: (_) => SystemPadding(
    //       child: AlertDialog(
    //         contentPadding: const EdgeInsets.all(16.0),
    //         content: Row(
    //           children: <Widget>[
    //             Expanded(
    //               child: TextField(
    //                 onChanged: (value) {
    //                   setState(() {
    //                     tempIp = value;
    //                   });
    //                 },
    //                 autofocus: true,
    //                 decoration: const InputDecoration(
    //                     labelText: 'Server IP', hintText: 'eg. 10.0.0.1'),
    //               ),
    //             ),
    //           ],
    //         ),
    //         actions: <Widget>[
    //           TextButton(
    //               child: const Text('Cancel'),
    //               onPressed: () {
    //                 Navigator.pop(context);
    //               }),
    //           TextButton(
    //               child: const Text('Update'),
    //               onPressed: () async {
    //                 final prefs = await SharedPreferences.getInstance();
    //                 prefs.setString("webrtcIP", tempIp);
    //                 Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    //                 Navigator.push(
    //                   context,
    //                   MaterialPageRoute(
    //                       builder: (BuildContext context) => const Telehealth()),
    //                 );
    //               })
    //         ],
    //       ),
    //     ),
    //   );
    // }

    @override
    Widget build(BuildContext context) => Scaffold(
          appBar: AppBar(
            backgroundColor: GFColors.DARK,
            leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                CupertinoIcons.back,
                color: GFColors.SUCCESS,
              ),
            ),
            title: const Text(
              'Telehealth',
              style: TextStyle(fontSize: 17),
            ),
            centerTitle: true,
            actions: <Widget>[
              IconButton(
                onPressed: getInfo,
                icon: const Icon(
                  Icons.refresh,
                  color: GFColors.PRIMARY,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.exit_to_app),
                tooltip: "Logout",
                color: GFColors.DANGER,
                onPressed: () async {
                  _signOut();
                  Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                },
              ),
            ],
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: _inCalling
              ? SizedBox(
                  width: 200.0,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        FloatingActionButton(
                          onPressed: _switchCamera,
                          child: const Icon(Icons.switch_camera),
                        ),
                        FloatingActionButton(
                          onPressed: _hangUp,
                          tooltip: 'Hangup',
                          backgroundColor: Colors.pink,
                          child: const Icon(Icons.call_end),
                        )
                      ]))
              : null,
          body: _inCalling
              ? OrientationBuilder(builder: (context, orientation) {
                  return Container(
                    child: Stack(children: <Widget>[
                      Positioned(
                          left: 0.0,
                          right: 0.0,
                          top: 0.0,
                          bottom: 0.0,
                          child: Container(
                            margin:
                                const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            child: RTCVideoView(_remoteRenderer),
                            decoration:
                                const BoxDecoration(color: Colors.black54),
                          )),
                      Positioned(
                        left: 20.0,
                        top: 20.0,
                        child: Container(
                          width: orientation == Orientation.portrait
                              ? 90.0
                              : 120.0,
                          height: orientation == Orientation.portrait
                              ? 120.0
                              : 90.0,
                          child: RTCVideoView(_localRenderer),
                          decoration:
                              const BoxDecoration(color: Colors.black54),
                        ),
                      ),
                    ]),
                  );
                })
              : SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: GFTabBarView(
                    controller: tabController,
                    children: <Widget>[
                      user == null
                          ? profileShimmer(context)
                          : Container(
                              child: ListView(
                                children: <Widget>[
                                  GFCard(
                                    boxFit: BoxFit.fill,
                                    colorFilter: ColorFilter.mode(
                                        Colors.black.withOpacity(0.67),
                                        BlendMode.darken),
                                    image: Image.asset(
                                      'lib/assets/images/image1.png',
                                      width: MediaQuery.of(context).size.width,
                                      fit: BoxFit.fitWidth,
                                    ),
                                    titlePosition: GFPosition.end,
                                    title: GFListTile(
                                      avatar: const GFAvatar(
                                        backgroundImage: AssetImage(
                                            'lib/assets/images/avatar8.png'),
                                      ),
                                      titleText: user != null
                                          ? user.displayName ??
                                              "Use edit icon on left to update"
                                          : "Invalid User",
                                      icon: GFIconButton(
                                        onPressed: () async {
                                          //   Navigator.push(
                                          //     context,
                                          //     MaterialPageRoute(
                                          //         builder: (BuildContext
                                          //                 context) =>
                                          //             //pass current user display name
                                          //             // FirebaseProfileScreen(
                                          //                 // dispName: user != null
                                          //                     // ? user.displayName ??
                                          //   //                       ""
                                          //   //                   : "")),
                                          //   // );
                                        },
                                        icon: const Icon(
                                          Icons.edit,
                                          color: GFColors.DANGER,
                                        ),
                                        type: GFButtonType.transparent,
                                      ),
                                    ),
                                  ),
                                  GFCard(
                                    boxFit: BoxFit.fill,
                                    colorFilter: ColorFilter.mode(
                                        Colors.black.withOpacity(0.67),
                                        BlendMode.darken),
                                    titlePosition: GFPosition.end,
                                    title: GFListTile(
                                      titleText: "WebRTC endpoint",
                                      subTitleText: (serverIP == "")
                                          ? "Not Configured\n(Telehealth restarts on IP change)"
                                          : serverIP,
                                      // icon: GFIconButton(
                                      // onPressed: _updateServerIp,
                                      icon: const Icon(
                                        Icons.settings,
                                        color: GFColors.DANGER,
                                      ),
                                      // type: GFButtonType.transparent,
                                    ),
                                  ),
                                  // ),
                                ],
                              ),
                            ),
                      ListView.builder(
                        itemCount: activeChats.length,
                        itemBuilder: (context, i) {
                          var chatDetail = activeChats[i];
                          return GFListTile(
                            avatar: const GFAvatar(
                              shape: GFAvatarShape.circle,
                              backgroundImage:
                                  AssetImage('lib/assets/images/avatar11.png'),
                            ),
                            titleText: chatDetail["targetName"],
                            subTitleText: chatDetail["lastMessage"] ?? "",
                            icon: GFIconButton(
                              onPressed: () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //       builder: (BuildContext context) =>
                                //           ChatScreen(
                                //             messagesId: chatDetail["messageId"],
                                //             heading: chatDetail["targetName"],
                                //             userId: userId,
                                //             // userName: user.displayName,
                                //             chatDocumentId:
                                //                 chatDetail["documentId"],
                                //           )),
                                // );
                              },
                              icon: const Icon(
                                Icons.message,
                                color: GFColors.FOCUS,
                              ),
                              type: GFButtonType.transparent,
                            ),
                          );
                        },
                      ),
                      (_peers.isEmpty)
                          ? const Center(
                              child: Text(
                                  "Invalid Server IP\nPlease fix it under profile tab",
                                  textAlign: TextAlign.center))
                          : ListView.builder(
                              itemCount: _peers.length,
                              itemBuilder: (context, i) {
                                var peer = _peers[i];
                                var self = (peer['id'] == userId);
                                return GFListTile(
                                  avatar: const GFAvatar(
                                    shape: GFAvatarShape.circle,
                                    backgroundImage: AssetImage(
                                        'lib/assets/images/avatar11.png'),
                                  ),
                                  titleText: peer['name'],
                                  subTitleText: peer['id'],
                                  icon: self
                                      ? const Text("Connected")
                                      : GFIconButton(
                                          onPressed: () =>
                                              _invitePeer(context, peer['id']),
                                          icon: const Icon(
                                            Icons.call,
                                            color: GFColors.PRIMARY,
                                          ),
                                          type: GFButtonType.transparent,
                                        ),
                                );
                              },
                            ),
                      ListView.builder(
                        itemCount: directory.length,
                        itemBuilder: (context, i) {
                          var targetUser = directory[i];
                          return GFListTile(
                            avatar: const GFAvatar(
                              shape: GFAvatarShape.circle,
                              backgroundImage:
                                  AssetImage('lib/assets/images/avatar11.png'),
                            ),
                            titleText: targetUser["name"],
                            subTitleText: targetUser["id"],
                            icon: GFIconButton(
                              onPressed: () => startChat(context, targetUser),
                              icon: const Icon(
                                Icons.message,
                                color: GFColors.FOCUS,
                              ),
                              type: GFButtonType.transparent,
                            ),
                          );
                        },
                      )
                    ],
                  )),
          bottomNavigationBar: _inCalling
              ? null
              : Container(
                  child: GFTabBar(
                    length: 1,
                    controller: tabController,
                    tabs: const [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.person,
                          ),
                          Text(
                            'Profile',
                            style: TextStyle(
                              fontSize: 10,
                            ),
                          )
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.chat,
                          ),
                          Text(
                            'Chats',
                            style: TextStyle(
                              fontSize: 10,
                            ),
                          )
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.call,
                          ),
                          Text(
                            'Calls',
                            style: TextStyle(
                              fontSize: 10,
                            ),
                          )
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.contacts,
                          ),
                          Text(
                            'Directory',
                            style: TextStyle(
                              fontSize: 10,
                            ),
                          )
                        ],
                      ),
                    ],
                    indicatorColor: GFColors.SUCCESS,
                    labelColor: GFColors.SUCCESS,
                    labelPadding: const EdgeInsets.all(8),
                    tabBarColor: GFColors.DARK,
                    unselectedLabelColor: GFColors.WHITE,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: Colors.white,
                      fontFamily: 'OpenSansBold',
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: Colors.black,
                      fontFamily: 'OpenSansBold',
                    ),
                  ),
                ),
        );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
