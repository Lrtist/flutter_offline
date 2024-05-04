import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

StreamTransformer<ConnectivityResult, ConnectivityResult> debounce(
  Duration debounceDuration,
) {
  var seenFirstData = false;
  Timer? debounceTimer;

  return StreamTransformer<ConnectivityResult, ConnectivityResult>.fromHandlers(
    handleData: (ConnectivityResult data, EventSink<ConnectivityResult> sink) {
      if (seenFirstData) {
        debounceTimer?.cancel();
        debounceTimer = Timer(debounceDuration, () => sink.add(data));
      } else {
        sink.add(data);
        seenFirstData = true;
      }
    },
    handleDone: (EventSink<ConnectivityResult> sink) {
      debounceTimer?.cancel();
      sink.close();
    },
  );
}

StreamTransformer<List<ConnectivityResult>, dynamic> startsWith(
  List<ConnectivityResult> data,
) {
  return StreamTransformer<List<ConnectivityResult>, dynamic>(
    (
      Stream<List<ConnectivityResult>> input,
      bool cancelOnError,
    ) {
      StreamController<List<ConnectivityResult>>? controller;
      late StreamSubscription<List<ConnectivityResult>> subscription;

      controller = StreamController<List<ConnectivityResult>>(
        sync: true,
        onListen: () => NewMethod(data, controller),
        onPause: ([Future<dynamic>? resumeSignal]) =>
            subscription.pause(resumeSignal),
        onResume: () => subscription.resume(),
        onCancel: () => subscription.cancel(),
      );

      subscription = input.listen(
        controller.add,
        onError: controller.addError,
        onDone: controller.close,
        cancelOnError: cancelOnError,
      );

      return controller.stream.listen(null);
    },
  );
}

void NewMethod(List<ConnectivityResult> data,
        StreamController<List<ConnectivityResult>>? controller) =>
    controller?.add(data);
