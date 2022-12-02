import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authentication extends StatefulWidget {
  const Authentication({super.key});

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late FirebaseAuth auth;
  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
    auth.authStateChanges().listen((User? user) {
      if (user == null) {
        debugPrint('User oturumu kapalı.');
      } else {
        debugPrint(
            'User oturumu açık. E-mail: ${user.email} ve e-mail durumu ${user.emailVerified}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Firebase Dersleri')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildTextFormField('E-Mail', _emailController),
            const SizedBox(height: 15),
            buildTextFormField('Parola', _passwordController),
            const SizedBox(height: 15),
            ElevatedButton(
                onPressed: () {
                  createUserEmailAndPassword();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Kayıt Ol')),
            ElevatedButton(
              onPressed: () {
                signInUserEmailAndPassword();
              },
              child: const Text('Giriş Yap'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                logOut();
              },
              child: const Text('Çıkış Yap'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
              onPressed: () {
                deleteAccount();
              },
              child: const Text('Hesabı Sil'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade900),
              onPressed: () {
                changePassword();
              },
              child: const Text('Şifreni Değiştir'),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              onPressed: () {
                googleGiris();
              },
              child: const Text('Google ile Giriş Yap'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
              onPressed: () {
                telefonlaGirisYap();
              },
              child: const Text('Telefon ile Giriş Yap'),
            ),
          ],
        ),
      ),
    );
  }

  TextFormField buildTextFormField(
      String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(label: Text(label)),
    );
  }

  void createUserEmailAndPassword() async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: _emailController.text.toString(),
          password: _passwordController.text.toString());

      User? myUser = userCredential.user;

      if (!myUser!.emailVerified) {
        myUser.sendEmailVerification();
        debugPrint('Doğrulama linki mail adresinize gönderildi');
      } else {
        debugPrint(
            'Kullanıcının emaili ${myUser.emailVerified}. Ilgili sayfaya gidebilir');
      }

      debugPrint(userCredential.toString());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void signInUserEmailAndPassword() async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: _emailController.text.toString(),
          password: _passwordController.text.toString());
      debugPrint(userCredential.toString());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void logOut() async {
    // google hesabını sil diyip tekrar oturum açmaya çalışınca pop up ekranı gelmiyor çözemedim!
    var googleUser = GoogleSignIn().currentUser;
    if (googleUser != null) {
      await GoogleSignIn().signOut();
    }

    await auth.signOut();
  }

  void deleteAccount() async {
    if (auth.currentUser != null) {
      await auth.currentUser!.delete();
      await GoogleSignIn().signOut();

      debugPrint('Hesabınız başarıyla silindi');
    } else {
      debugPrint('Kullanıcı oturum açmadığından dolayı silinemez');
    }
  }

  void changePassword() async {
    // aynısını email için de tanımlayabilirsin. parametreleri değiştir.
    try {
      await auth.currentUser!.updatePassword('enes4116');
      await auth.signOut();
      debugPrint('Sifreniz Güncellendi');
    } on FirebaseAuthException catch (e) {
      // firebase ile geliştirilen uygulamalarda uygulamayı kapatınca oturumdan çıkış yapmaz.
      // Uzun süre açık kalan oturumlarda şifre değiştilmek istenirse bu kod bloğuna giriş yapacaktır..
      if (e.code == 'requires-recent-login') {
        debugPrint('Tekrar giris yapılacak');
        var credential = EmailAuthProvider.credential(
            email: _emailController.text.toString(),
            password: _passwordController.text.toString());
        await auth.currentUser!.reauthenticateWithCredential(credential);

        await auth.currentUser!.updatePassword('yeniSifre');
        await auth.signOut();
        debugPrint('Sifreniz Güncellendi');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void googleGiris() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    await FirebaseAuth.instance.signInWithCredential(credential);
  }

  void telefonlaGirisYap() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+905436234972',
      verificationCompleted: (PhoneAuthCredential credential) async {
        debugPrint('verification complated tetiklendi');
        debugPrint(credential.toString());
        await auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseException e) {
        debugPrint(e.toString());
      },
      codeSent: (verificationId, int? resendToken) async {
        String _smsCode = '123456';
        debugPrint('code sent tetiklendi');
        var _credential = PhoneAuthProvider.credential(
            verificationId: verificationId, smsCode: _smsCode);
        await auth.signInWithCredential(_credential);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        debugPrint('code auto retrieval timeout');
      },
    );
  }
}
