import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'dart:async';

typedef OnMessageCallback = void Function(dynamic msg);
typedef OnCloseCallback = void Function(int code, String reason);
typedef OnOpenCallback = void Function();

class SimpleWebSocket {
  // final String _url;
  var _socket;
  // OnOpenCallback onOpen;
  // OnMessageCallback onMessage;
  // OnCloseCallback onClose;
  // SimpleWebSocket(this._url);

  connect() async {
    // try {
    //_socket = await WebSocket.connect(_url);
    // _socket = await _connectForSelfSignedCert(_url);
    // onOpen();
    // _socket.listen((data) {
    //   onMessage(data);
    // }, onDone: () {
    //   onClose(_socket.closeCode, _socket.closeReason);
    //   });
    // } catch (e) {
    //   onClose(500, e.toString());
  }
}

// send(data) {
//   if (_socket != null) {
//     _socket.add(data);
//     print('send: $data');
//   }
// }

// close() {
//   if (_socket != null) _socket.close();
// }

Future<WebSocket> _connectForSelfSignedCert(url) async {
  try {
    Random r = Random();
    String key = base64.encode(List<int>.generate(8, (_) => r.nextInt(255)));
    HttpClient client = HttpClient(context: SecurityContext());
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
      print('SimpleWebSocket: Allow self-signed certificate => $host:$port. ');
      return true;
    };

    HttpClientRequest request =
        await client.getUrl(Uri.parse(url)); // form the correct url here
    request.headers.add('Connection', 'Upgrade');
    request.headers.add('Upgrade', 'websocket');
    request.headers
        .add('Sec-WebSocket-Version', '13'); // insert the correct version here
    request.headers.add('Sec-WebSocket-Key', key.toLowerCase());

    HttpClientResponse response = await request.close();
    // ignore: close_sinks
    Socket socket = await response.detachSocket();
    var webSocket = WebSocket.fromUpgradedSocket(
      socket,
      protocol: 'signaling',
      serverSide: false,
    );

    return webSocket;
  } catch (e) {
    rethrow;
  }
}
// }
