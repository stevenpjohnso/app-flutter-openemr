import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'common.dart';

class NetworkUtil {
  // next three lines makes this class a Singleton
  static final NetworkUtil _instance = NetworkUtil.internal();
  NetworkUtil.internal();
  factory NetworkUtil() => _instance;

  final JsonDecoder _decoder = const JsonDecoder();

  // Future<dynamic> get(String url, {required Map headers}) {
  //   if (!isValidUrl(url)) {
  //     return Future.error("Invalid API URL");
  //   }
  //   return http.get(url, headers: headers).then((http.Response response) {
  //     final String res = response.body;
  //     final int statusCode = response.statusCode;

  //     if (statusCode < 200 || statusCode > 400) {
  //       throw Exception("Error while fetching data");
  //     }
  //     return _decoder.convert(res);
  //   });
  // }

  // Future<dynamic> post(String url, {Map headers, body, encoding}) {
  //   if (!isValidUrl(url)) {
  //     return Future.error("Invalid API URL");
  //   }
  //   return http
  //       .post(url,
  //           body: json.encode(body), headers: headers, encoding: encoding)
  //       .then((http.Response response)
  //        {
  //     final res = response.body;
  //     final int statusCode = response.statusCode;
  //     if (statusCode == 401) {
  //       throw Exception("${statusCode}Invalid Credentials");
  //     } else if (statusCode == 400) {
  //       final resData = json.decode(res);
  //       var validationErrorData = resData['validationErrors'];
  //       List<Map<String, dynamic>> errors = [];
  //       validationErrorData.entries.forEach(((err) => errors.add(err.value)));
  //       if (errors.isNotEmpty) {
  //         throw Exception("$statusCode ${errors[0].values}");
  //       }
  //     } else if (statusCode < 200 || statusCode > 400) {
  //       throw Exception("${statusCode}Error while fetching data");
  //     }
  //     return _decoder.convert(res);
  //   });
  // }

  Future<dynamic> upload(String url, File img) async {
    if (!isValidUrl(url)) {
      return Future.error("Invalid API URL");
    }

    try {
      var streamed = http.ByteStream(Stream.castFrom(img.openRead()));
      var length = await img.length();

      var uri = Uri.parse(url);

      var request = http.MultipartRequest("POST", uri);
      var multipartFile = http.MultipartFile('image', streamed, length,
          filename: basename(img.path),
          contentType: MediaType('image', 'jpeg'));

      request.files.add(multipartFile);
      var response = await request.send();
      final int statusCode = response.statusCode;
      if (statusCode == 401) {
        throw Exception("${statusCode}Invalid Credentials");
      } else if (statusCode < 200 || statusCode > 400) {
        throw Exception("${statusCode}Error while fetching data");
      }
      var data = await response.stream.bytesToString();
      return {"err": null, "data": data};
    } catch (err) {
      return {"err": err, "data": null};
    }
  }
}
