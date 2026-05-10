import 'package:get/get.dart';

import '../controllers/hapus_produk_controller.dart';

class HapusProdukBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HapusProdukController>(
      () => HapusProdukController(),
    );
  }
}
