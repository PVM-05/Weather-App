import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  // Lấy vị trí hiện tại
  Future<Position> getCurrentLocation() async {
    // Kiểm tra và yêu cầu quyền vị trí
    var permission = await Permission.location.request();
    if (permission.isDenied) {
      throw Exception('Quyền vị trí bị từ chối');
    }
    if (permission.isPermanentlyDenied) {
      throw Exception('Quyền vị trí bị từ chối vĩnh viễn. Vui lòng cấp quyền trong cài đặt.');
    }

    // Kiểm tra xem dịch vụ vị trí có bật không
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Dịch vụ vị trí đang tắt. Vui lòng bật dịch vụ vị trí.');
    }

    // Lấy vị trí hiện tại
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Lắng nghe thay đổi vị trí theo thời gian thực
  Stream<Position> getLocationStream() async* {
    // Kiểm tra và yêu cầu quyền vị trí
    var permission = await Permission.location.status;
    if (permission.isDenied) {
      permission = await Permission.location.request();
      if (permission.isDenied) {
        throw Exception('Quyền vị trí bị từ chối');
      }
    }
    if (permission.isPermanentlyDenied) {
      throw Exception('Quyền vị trí bị từ chối vĩnh viễn. Vui lòng cấp quyền trong cài đặt.');
    }

    // Kiểm tra dịch vụ vị trí
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Dịch vụ vị trí đang tắt. Vui lòng bật dịch vụ vị trí.');
    }

    // Trả về stream vị trí
    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Cập nhật khi vị trí thay đổi quá 10 mét
      ),
    );
  }
}