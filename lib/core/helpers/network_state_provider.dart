import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final networkStateProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  
  // Emit initial state
  final initialResult = await connectivity.checkConnectivity();
  yield !initialResult.contains(ConnectivityResult.none);

  // Listen to changes
  await for (final result in connectivity.onConnectivityChanged) {
    yield !result.contains(ConnectivityResult.none);
  }
});

final wifiStateProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  
  // Emit initial state
  final initialResult = await connectivity.checkConnectivity();
  yield initialResult.contains(ConnectivityResult.wifi);

  // Listen to changes
  await for (final result in connectivity.onConnectivityChanged) {
    yield result.contains(ConnectivityResult.wifi);
  }
});
