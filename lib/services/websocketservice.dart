import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;


  void connect(String url) {
    final wsUrl = url.isNotEmpty ? url : 'https://websocketservice.onrender.com';
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
  }


  Stream<dynamic> get messages => _channel?.stream ?? const Stream.empty();


  void sendMessage(String message) {
    _channel?.sink.add(message);
  }


  void sendJson(Map<String, dynamic> data) {
    _channel?.sink.add(jsonEncode(data));
  }


  void close() {
    _channel?.sink.close();
    _channel = null;
  }
}
