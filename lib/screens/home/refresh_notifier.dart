import 'dart:async';

class RefreshNotifier {
  final _controller = StreamController.broadcast();

  Stream get onRefresh => _controller.stream;

  void refreshScreen() {
    _controller.sink.add(null);
  }

  void dispose() {
    _controller.close();
  }
}
