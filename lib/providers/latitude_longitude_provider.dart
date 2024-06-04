import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provide latitude and longitude data

class LatitudeLongitudeNotifier extends StateNotifier<List<double>> {
  LatitudeLongitudeNotifier() : super([37.1289771, -84.0832646]);

  void updateLatitude(double latitude, double longitude) {
    state = [latitude, longitude];
  }
}

final latitudeLongitudeProvider =
    StateNotifierProvider<LatitudeLongitudeNotifier, List<double>>((ref) {
  return LatitudeLongitudeNotifier();
});
