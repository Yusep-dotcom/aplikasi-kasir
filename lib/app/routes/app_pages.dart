import 'package:aplikasi_kasir/app/core/middleware/auth_middleware.dart';
import 'package:get/get.dart';

import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/form_produk/bindings/form_produk_binding.dart';
import '../modules/form_produk/views/form_produk_view.dart';
import '../modules/hapus_produk/bindings/hapus_produk_binding.dart';
import '../modules/hapus_produk/views/hapus_produk_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/kasir/bindings/kasir_binding.dart';
import '../modules/kasir/views/kasir_view.dart';
import '../modules/laporan/bindings/laporan_binding.dart';
import '../modules/laporan/views/laporan_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/produk/bindings/produk_binding.dart';
import '../modules/produk/views/produk_view.dart';
import '../modules/transaksi/bindings/transaksi_binding.dart';
import '../modules/transaksi/views/transaksi_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.KASIR,
      page: () => const KasirView(),
      binding: KasirBinding(),
      transition: Transition.noTransition,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.PRODUK,
      page: () => const ProdukView(),
      binding: ProdukBinding(),
      transition: Transition.noTransition,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.FORM_PRODUK,
      page: () => const FormProdukView(),
      binding: FormProdukBinding(),
      transition: Transition.noTransition,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.TRANSAKSI,
      page: () => const TransaksiView(),
      binding: TransaksiBinding(),
      transition: Transition.noTransition,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.LAPORAN,
      page: () => const LaporanView(),
      binding: LaporanBinding(),
      transition: Transition.noTransition,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.HAPUS_PRODUK,
      page: () => const HapusProdukView(),
      binding: HapusProdukBinding(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
