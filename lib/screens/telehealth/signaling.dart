import 'dart:convert';
import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:openemr/utils/websocket.dart';

enum SignalingState {
  CallStateNew,
  CallStateRinging,
  CallStateInvite,
  CallStateConnected,
  CallStateBye,
  ConnectionOpen,
  ConnectionClosed,
  ConnectionError,
}

/*
 * callbacks for Signaling API.
 */
typedef SignalingStateCallback = void Function(SignalingState state);
typedef StreamStateCallback = void Function(MediaStream stream);
typedef OtherEventCallback = void Function(dynamic event);
typedef DataChannelMessageCallback = void Function(
    RTCDataChannel dc, RTCDataChannelMessage data);
typedef DataChannelCallback = void Function(RTCDataChannel dc);

class Signaling {
  final JsonEncoder _encoder = const JsonEncoder();
  late final String _selfId;
  late SimpleWebSocket _socket;
  var _sessionId;
  // final late _host;
  final _port = 8086;
  final _peerConnections = <String, RTCPeerConnection>{};
  final _dataChannels = <String, RTCDataChannel>{};
  final _remoteCandidates = [];

  late MediaStream _localStream;
  late List<MediaStream> _remoteStreams;
  late StreamStateCallback onLocalStream;
  late StreamStateCallback onAddRemoteStream;
  late StreamStateCallback onRemoveRemoteStream;
  late OtherEventCallback onPeersUpdate;
  late DataChannelMessageCallback onDataChannelMessage;
  late DataChannelCallback onDataChannel;

  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'url': 'stun:stun.l.google.com:19302'},
    ]
  };

  final Map<String, dynamic> _config = {
    'mandatory': {},
    'optional': [
      {'DtlsSrtpKeyAgreement': true},
    ],
  };

  final Map<String, dynamic> _constraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
    'optional': [],
  };

  final Map<String, dynamic> _dcConstraints = {
    'mandatory': {
      'OfferToReceiveAudio': false,
      'OfferToReceiveVideo': false,
    },
    'optional': [],
  };

  // Signaling(this._host, this._selfId);

  close() {
    _localStream.dispose();
    _localStream;

    _peerConnections.forEach((key, pc) {
      pc.close();
    });
    // _socket.close();
  }

  void switchCamera() {
    _localStream.getVideoTracks()[0].switchCamera();
  }

  void invite(String peerId, String media) {
    _sessionId = '$_selfId-$peerId';

    // onStateChange(SignalingState.CallStateNew);

    _createPeerConnection(peerId, media).then((pc) {
      _peerConnections[peerId] = pc;
      if (media == 'data') {
        _createDataChannel(peerId, pc);
      }
      _createOffer(peerId, pc, media);
    });
  }

  void bye() {
    _send('bye', {
      'session_id': _sessionId,
      'from': _selfId,
    });
  }

  void onMessage(message) async {
    Map<String, dynamic> mapData = message;
    var data = mapData['data'];

    switch (mapData['type']) {
      case 'peers':
        {
          List<dynamic> peers = data;
          Map<String, dynamic> event = <String, dynamic>{};
          event['self'] = _selfId;
          event['peers'] = peers;
          onPeersUpdate(event);
        }
        break;
      case 'offer':
        {
          var id = data['from'];
          var description = data['description'];
          var media = data['media'];
          var sessionId = data['session_id'];
          _sessionId = sessionId;

          // onStateChange(SignalingState.CallStateNew);

          var pc = await _createPeerConnection(id, media);
          _peerConnections[id] = pc;
          await pc.setRemoteDescription(
              RTCSessionDescription(description['sdp'], description['type']));
          await _createAnswer(id, pc, media);
          if (_remoteCandidates.isNotEmpty) {
            _remoteCandidates.forEach((candidate) async {
              await pc.addCandidate(candidate);
            });
            _remoteCandidates.clear();
          }
        }
        break;
      case 'answer':
        {
          var id = data['from'];
          var description = data['description'];

          var pc = _peerConnections[id];
          if (pc != null) {
            await pc.setRemoteDescription(
                RTCSessionDescription(description['sdp'], description['type']));
          }
        }
        break;
      case 'candidate':
        {
          var id = data['from'];
          var candidateMap = data['candidate'];
          var pc = _peerConnections[id];
          RTCIceCandidate candidate = RTCIceCandidate(candidateMap['candidate'],
              candidateMap['sdpMid'], candidateMap['sdpMLineIndex']);
          if (pc != null) {
            await pc.addCandidate(candidate);
          } else {
            _remoteCandidates.add(candidate);
          }
        }
        break;
      case 'leave':
        {
          var id = data;
          var pc = _peerConnections.remove(id);
          _dataChannels.remove(id);

          _localStream.dispose();
          _localStream;

          if (pc != null) {
            pc.close();
          }
          _sessionId = null;
          // onStateChange(SignalingState.CallStateBye);
        }
        break;
      case 'bye':
        {
          var to = data['to'];
          var sessionId = data['session_id'];
          print('bye: ' + sessionId);

          _localStream.dispose();
          _localStream;

          var pc = _peerConnections[to];
          if (pc != null) {
            pc.close();
            _peerConnections.remove(to);
          }

          var dc = _dataChannels[to];
          if (dc != null) {
            dc.close();
            _dataChannels.remove(to);
          }

          _sessionId = null;
          // onStateChange(SignalingState.CallStateBye);
        }
        break;
      case 'keepalive':
        {
          print('keepalive response!');
        }
        break;
      default:
        break;
    }
  }

  void connect(name) async {
    // var url = 'https://$_host:$_port/ws';
    // _socket = SimpleWebSocket(url);

    // print('connect to $url');

    // _socket.onOpen = () {
    //   print('onOpen');
    //   // onStateChange(SignalingState.ConnectionOpen);
    //   _send('new', {'name': name, 'id': _selfId, 'user_agent': "initiator"});
    // };

    // _socket.onMessage = (message) {
    //   print('Received data: ' + message);
    //   JsonDecoder decoder = const JsonDecoder();
    //   onMessage(decoder.convert(message));
    // };

    // _socket.onClose = (int code, String reason) {
    //   print('Closed by server [$code => $reason]!');
    //   // onStateChange(SignalingState.ConnectionClosed);
    // };

    await _socket.connect();
  }

  Future<MediaStream> createStream(media) async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'mandatory': {
          'minWidth': '640',
          'minHeight': '480',
          'minFrameRate': '30',
        },
        'facingMode': 'user',
        'optional': [],
      }
    };

    MediaStream stream = await navigator.getUserMedia(mediaConstraints);
    onLocalStream(stream);
    return stream;
  }

  _createPeerConnection(id, media) async {
    if (media != 'data') _localStream = await createStream(media);
    RTCPeerConnection pc = await createPeerConnection(_iceServers, _config);
    if (media != 'data') pc.addStream(_localStream);
    pc.onIceCandidate = (candidate) {
      _send('candidate', {
        'to': id,
        'from': _selfId,
        'candidate': {
          'sdpMLineIndex': candidate.sdpMLineIndex,
          'sdpMid': candidate.sdpMid,
          'candidate': candidate.candidate,
        },
        'session_id': _sessionId,
      });
    };

    pc.onIceConnectionState = (state) {};

    pc.onAddStream = (stream) {
      onAddRemoteStream(stream);
      //_remoteStreams.add(stream);
    };

    pc.onRemoveStream = (stream) {
      onRemoveRemoteStream(stream);
      _remoteStreams.removeWhere((it) {
        return (it.id == stream.id);
      });
    };

    pc.onDataChannel = (channel) {
      _addDataChannel(id, channel);
    };

    return pc;
  }

  _addDataChannel(id, RTCDataChannel channel) {
    channel.onDataChannelState = (e) {};
    channel.onMessage = (RTCDataChannelMessage data) {
      onDataChannelMessage(channel, data);
    };
    _dataChannels[id] = channel;

    onDataChannel(channel);
  }

  _createDataChannel(id, RTCPeerConnection pc, {label = 'fileTransfer'}) async {
    RTCDataChannelInit dataChannelDict = RTCDataChannelInit();
    RTCDataChannel channel = await pc.createDataChannel(label, dataChannelDict);
    _addDataChannel(id, channel);
  }

  _createOffer(String id, RTCPeerConnection pc, String media) async {
    try {
      RTCSessionDescription s =
          await pc.createOffer(media == 'data' ? _dcConstraints : _constraints);
      pc.setLocalDescription(s);
      _send('offer', {
        'to': id,
        'from': _selfId,
        'description': {'sdp': s.sdp, 'type': s.type},
        'session_id': _sessionId,
        'media': media,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  _createAnswer(String id, RTCPeerConnection pc, media) async {
    try {
      RTCSessionDescription s = await pc
          .createAnswer(media == 'data' ? _dcConstraints : _constraints);
      pc.setLocalDescription(s);
      _send('answer', {
        'to': id,
        'from': _selfId,
        'description': {'sdp': s.sdp, 'type': s.type},
        'session_id': _sessionId,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  _send(event, data) {
    var request = {};
    request["type"] = event;
    request["data"] = data;
    // _socket.send(_encoder.convert(request));
  }
}
