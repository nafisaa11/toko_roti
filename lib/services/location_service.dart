import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }
    return await Geolocator.getCurrentPosition();
  }

   Future<String> getAddressFromCoordinates(Position position) async {
    try {
      // Menggunakan placemarkFromCoordinates untuk mendapatkan detail alamat
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Ambil hasil pertama (biasanya yang paling akurat)
      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks[0];
        // Gabungkan komponen alamat menjadi satu string yang mudah dibaca
        return "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";
      } else {
        return "Alamat tidak ditemukan.";
      }
    } catch (e) {
      print('Error getting address: $e');
      throw Exception('Gagal mengubah koordinat menjadi alamat.');
    }
  }
}
