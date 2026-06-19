import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/login_controller.dart';
import '../../../core/theme/app_theme.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE9E9E9),
      // F0EBE3 = warna krem/beige seperti di desainmu
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ═══════════════════════════════════
          // SISI KIRI — Branding & Ilustrasi
          // ═══════════════════════════════════
          Expanded(
            child: Container(
              color: const Color(0xE9E9E9),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lingkaran dekoratif atas kiri
                  // (seperti di desain ada 3 lingkaran merah kecil)
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40, left: 40),
                      child: Row(
                        children: [
                          _circle(18, AppTheme.primary.withOpacity(0.8)),
                          const SizedBox(width: 8),
                          _circle(12, AppTheme.primary.withOpacity(0.5)),
                          const SizedBox(width: 6),
                          _circle(8, AppTheme.primary.withOpacity(0.3)),
                        ],
                      ),
                    ),
                  ),

                  // Nama toko

                  // Teks bawah
                  _formLogin(),
                ],
              ),
            ),
          ),

          // ═══════════════════════════════════
          // SISI KANAN — Form Login (terpusat)
          // ═══════════════════════════════════
        ],
      ),
    );
  }

  Expanded _formLogin() {
    return Expanded(
      child: Container(
        color: Color(0xFFE9E9E9),
        child: Center(
          child: Container(
            width: 380,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              // mainAxisSize.min = Container hanya setinggi isinya
              children: [
                // Judul form
                Text(
                  'Wellcome Back',
                  style: GoogleFonts.alexBrush(
                    fontSize: 32,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 32),

                // Input Username/Email
                _buildInput(
                  controller: controller.emailController,
                  hint: 'Username',
                  icon: Icons.person_outline,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),

                // Input Password
                Obx(
                  () => _buildInput(
                    controller: controller.passwordController,
                    hint: 'Password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isPasswordVisible: controller.isPasswordVisible.value,
                    onTogglePassword: controller.togglePasswordVisibility,
                  ),
                ),
                const SizedBox(height: 28),

                // Tombol LOGIN
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'LOGIN',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Forgot password
                TextButton(
                  onPressed: () {
                    Get.snackbar(
                      'Lupa Password?',
                      'Hubungi admin toko untuk reset password',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  child: Text(
                    'Forgot password?',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.primary.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper bikin lingkaran dekoratif
  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  // Helper bikin input field yang konsisten
  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onTogglePassword,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword && !isPasswordVisible,
      autofocus: true,
      // obscureText = sembunyikan teks jadi ***
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: AppTheme.textSecondary.withOpacity(0.5),
          fontSize: 13,
        ),
        prefixIcon: Icon(icon, size: 18, color: AppTheme.textSecondary),
        // suffixIcon = icon di kanan, hanya untuk password
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                  color: AppTheme.textSecondary,
                ),
                onPressed: onTogglePassword,
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF9F6F3),
        // F9F6F3 = warna krem sangat muda untuk input
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
      ),
    );
  }
}
