import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../constants/firebase.dart';
import '../pages/PaginaPrincipal.dart';
import '../models/Pessoa.dart';
import '../pages/PaginaLogin.dart';

class AuthException implements Exception {
  String mensagem;

  AuthException(this.mensagem);
}

class UsuarioController extends GetxController {
  String usersCollection = "users";
  bool firstLogin = false;

  static UsuarioController instance = Get.find();
  late Rx<User?> firebaseUser;
  Rx<Pessoa> pessoaModel = Pessoa().obs;
  RxBool isLoggedIn = false.obs;

  @override
  void onReady() {
    super.onReady();
    firebaseUser = Rx<User?>(firebaseAuth.currentUser);
    firebaseUser.bindStream(firebaseAuth.userChanges());
    ever(firebaseUser, _setInitialScreenAndData);
  }

  _setInitialScreenAndData(User? user) async {
    if (user == null) {
      Get.offAll(() => const PaginaLogin());
    } else {
      Get.offAll(() => const PaginaPrincipal());
    }
  }

  Stream<Pessoa> listenToUser() => firebaseFirestore
      .collection(usersCollection)
      .doc(firebaseUser.value?.uid)
      .snapshots()
      .map((snapshot) => Pessoa.fromSnapshot(snapshot));

  loginGoogle() async {
    try {
      final googleSignIn = GoogleSignIn(scopes: ['email']);
      final googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount == null) {
        return;
      }

      final googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      await firebaseAuth.signInWithCredential(credential).then((result) async {
        if (result.user?.uid == null) {
          return;
        }
        String? userId = result.user?.uid;
        bool docExists = await checkIfUsuarioExists(userId);
        if (!docExists) {
          _addUserToFirestoreGoogle(userId!, googleSignInAccount);
        }
      });
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw AuthException(
              'Esta conta já existe com um provedor diferente!');
        case 'invalid-credential':
          throw AuthException('Um erro desconhecido foi encontrado!');
        case 'operation-not-allowed':
          throw AuthException('Operação não permitida!');
        case 'user-disabled':
          throw AuthException(
              'O usuário que você tentou conectar está desabilitado!');
        case 'user-not-found':
          throw AuthException(
              'O usuário que você tentou conectar não foi encontrado!');
      }
    } catch (e) {
      throw AuthException("Um erro desconhecido foi encontrado");
    }
  }

  void logout() async {
    firebaseAuth.signOut();
  }

  _addUserToFirestoreGoogle(String userId, var googleSignInAccount) async {
    await firebaseFirestore.collection(usersCollection).doc(userId).set({
      'id': userId,
      'email': googleSignInAccount.email,
      'firstLogin': true,
    });
  }

  Future<bool> checkIfUsuarioExists(String? usuarioId) async {
    try {
      var collectionRef = firebaseFirestore.collection('users');

      var doc = await collectionRef.doc(usuarioId).get();
      return doc.exists;
    } catch (e) {
      rethrow;
    }
  }
}
