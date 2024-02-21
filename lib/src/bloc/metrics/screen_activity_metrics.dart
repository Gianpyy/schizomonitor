import 'dart:async';
import 'package:carp_core/carp_core.dart';
import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';
import 'package:magicarp/src/sensing/sensing.dart';


class ScreenActivityMetrics {
  int _numberOfUses = 0;
  int _totalUseTime = 0;
  double _averageUseTime = 0.0;

  final Stopwatch _stopwatch = Stopwatch();

  StreamSubscription<Measurement>? _subscription;

  /// Start listening to screen events from the measurements stream
  void startListening() {
    _subscription = Sensing().controller!.measurements
        .where((measurement) => measurement.data.format.toString() == DeviceSamplingPackage.SCREEN_EVENT)
        .listen((data) {
          processData(data);
    }, onDone: () {
          handleDone();
    }, onError: (error) {
          handleError(error);
    });
  }

  /// Process the data received by the measurements stream
  void processData(Measurement measurement) {
    ScreenEvent screenEvent = measurement.data as ScreenEvent;
    info("Received data: ${screenEvent.screenEvent}");

    if(screenEvent.screenEvent == "SCREEN_ON") {
      // When the screen is turned on, increment the number of uses and start
      // counting the time that the phone is on use
      _numberOfUses++;
      _stopwatch.start();

      info("New use detected! Total numer of uses: $_numberOfUses");

    } else {
      info("Screen turned off, calculating metrics");

      // When the screen is turned off, stop counting the time and increment the
      // total use time and the average use time
      _stopwatch.stop();
      _totalUseTime += _stopwatch.elapsedMilliseconds;
      _averageUseTime = (_totalUseTime / _numberOfUses);
      _stopwatch.reset();
    }

  }

  /// Handle when the stream is done
  void handleDone() {
    info("Stream done.");
  }

  /// Handle errors in the data stream
  void handleError(error) {
    info("Error: $error");
  }

  /// Stop listening to the stream
  void stopListening() {
    _subscription?.cancel();
  }

  /// The total number of uses of the phone by the user
  int get numberOfUses => _numberOfUses;

  /// The average use time of the phone by the user
  double get averageUseTime => _averageUseTime;

  // The total use time of the phone by the user
  int get totalUseTime => _totalUseTime;
}