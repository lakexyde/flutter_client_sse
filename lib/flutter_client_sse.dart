library flutter_client_sse;

import 'dart:convert';
import 'package:http/http.dart' as http;
part 'sse_event_model.dart';

class SSEClient {
  static late http.Client _client;
  static Stream<SSEModel> subscribeToSSE(String url, String token) async* {
    print("--SUBSCRIBING TO SSE---");
    while (true) {
      try {
        _client = http.Client();
        var request = new http.Request("GET", Uri.parse(url));
        request.headers["Cache-Control"] = "no-cache";
        request.headers["Accept"] = "text/event-stream";
        request.headers["Cookie"] = token;
        Future<http.StreamedResponse> response = _client.send(request);
        await for (final data in response.asStream()) {
          final rawData = await data.stream.transform(utf8.decoder).join();
          final event = rawData.split("\n")[1];
          if (event != '') {
            yield SSEModel.fromData(rawData);
          }
        }
      } catch (e) {
        print('---ERROR---');
        print(e);
        yield SSEModel(data: '', id: '', event: '');
      }
      await Future.delayed(Duration(seconds: 1), () {});
    }
  }

  static void unsubscribeFromSSE() {
    _client.close();
  }
}
