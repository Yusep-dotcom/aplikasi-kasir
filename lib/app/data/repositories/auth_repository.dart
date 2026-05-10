import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthRepository {
  // Instance Firebase Auth dan Firestore
  // Analoginya: ini adalah "mesin" yang kita pakai
  // untuk bicara dengan Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fungsi login
  // Mengembalikan UserModel kalau berhasil
  // Melempar Exception kalau gagal
  Future<UserModel> login(String email, String password) async {
    try {
      // Coba login ke Firebase Auth
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;
      // Setelah login berhasil, ambil data user dari Firestore
      // untuk tahu role-nya (admin/kasir)
      final doc = await _db.collection('users').doc(uid).get();

      if (!doc.exists) {
        throw Exception('Data user tidak ditemukan');
      }

      return UserModel.fromMap(doc.data()!, uid);

    } on FirebaseAuthException catch (e) {
      // FirebaseAuthException = error khusus dari Firebase Auth
      // kita tangkap dan ubah jadi pesan yang ramah
      if (e.code == 'user-not-found') {
        throw Exception('Email tidak terdaftar');
      } else if (e.code == 'wrong-password') {
        throw Exception('Password salah');
      } else {
        throw Exception('Login gagal: ${e.message}');
      }
    }
  }

  // Fungsi logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Cek apakah user sedang login
  // Berguna saat app dibuka ulang
  User? get currentUser => _auth.currentUser;
}