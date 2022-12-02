import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FirestoreKullanimi extends StatelessWidget {
  FirestoreKullanimi({super.key});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late var _yeniDocId;
  late final StreamSubscription _userSubscribe;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Firestore Dersleri'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  veriSet();
                },
                child: const Text('Veri Set')),
            ElevatedButton(
                onPressed: () {
                  veriEkle();
                },
                child: const Text('Veri Ekle')),
            ElevatedButton(
                onPressed: () {
                  veriGuncelle();
                },
                child: const Text('Veri Güncelle')),
            ElevatedButton(
                onPressed: () {
                  veriSil();
                },
                child: const Text('Veri Sil')),
            ElevatedButton(
                onPressed: () {
                  verileriOneTimeOku();
                },
                child: const Text('Verileri one time oku')),
            ElevatedButton(
                onPressed: () {
                  verileriRealTimeOku();
                },
                child: const Text('Verileri real time oku')),
            ElevatedButton(
                onPressed: () {
                  batchKavrami();
                },
                child: const Text('Batch Kavramı')),
            ElevatedButton(
                onPressed: () {
                  transactionKavrami();
                },
                child: const Text('Transaction Kavramı')),
            ElevatedButton(
                onPressed: () {
                  imageUploadKameraGaleri();
                },
                child: const Text('Resim eklemek')),
          ],
        ),
      ),
    );
  }

  void veriEkle() async {
    Map<String, dynamic> _eklenecekUser = <String, dynamic>{};
    _eklenecekUser['isim'] = 'enes';
    _eklenecekUser['yas'] = 22;
    _eklenecekUser['ogrenciMi'] = true;
    _eklenecekUser['adres'] = {'il': 'Kocaeli', 'ilçe': 'Körfez'};
    _eklenecekUser['renkler'] = FieldValue.arrayUnion(['mavi', 'yeşil']);
    _eklenecekUser['createdAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('users').add(_eklenecekUser);
  }

  void veriSet() async {
    var _eklenecekOkul = {'okul': 'Fırat Üniversitesi'};
    var yas = {'yas': FieldValue.increment(1)};

    await _firestore
        .doc('users/a3WVuGSYhTc6eg7wiWo0')
        .set(_eklenecekOkul, SetOptions(merge: true));

    await _firestore
        .doc('users/a3WVuGSYhTc6eg7wiWo0')
        .set(yas, SetOptions(merge: true));
  }

  void veriGuncelle() async {
    await _firestore
        .doc('users/a3WVuGSYhTc6eg7wiWo0')
        .update({'isim': 'güncel enes', 'Flutter': true});
  }

  void veriSil() async {
    await _firestore.doc('users/a3WVuGSYhTc6eg7wiWo0').delete();
    // await _firestore
    //     .doc('users/a3WVuGSYhTc6eg7wiWo0')
    //     .update({'okul': FieldValue.delete()});  Bu alan doc içindeki fieldin silinmesine olanak sağlar
    // veri ekle ye bas sonra sete bastığında eklenen coleksiyon değişsin!
    //set ile update arasındaki fark;
    //Set: document ref id si mevcut değilse o ID ile yeni bir doc oluşturur1
    //Update: Parametre geçilen ref id si mevcut değilse hata fırlatır. Olmayan bir field girilirse ör: 'aaa':enes doc icine aaa adlı field olusturup enese esitler }
  }

  verileriOneTimeOku() async {
    var _userDocuments = await _firestore.collection('users').get();

    for (var element in _userDocuments.docs) {
      debugPrint('Döküman ID: ${element.id}');
      Map userMap = element.data();
      debugPrint(userMap['adres']['il']);
    }

    var _enesDoc = await _firestore.doc('users/0nW9FNRHVvnGRdNfnLor').get();
    debugPrint(_enesDoc.data()!['isim']);
  }

  verileriRealTimeOku() async {
    var _userStream = await _firestore.collection('users').snapshots();
    _userSubscribe = _userStream.listen(
      //aboneliği iptal etmek için :  _userSubscribe.cancel();
      (event) {
        event.docChanges.forEach(
          //docchanges bir değişiklik anında tüm koleksiyonu döndürür. doc kullanırsan (event.doc.foreach) sadece değişimin yapıldığı docu döner
          //docchanges ve docs liste döndürdüğü için foreach ile tüm elemanların içindeki dataya tek tek erişiyorsun.
          (element) {
            debugPrint(element.doc.data().toString());
          },
        );
      },
    );

    //üstteki şekilde koleksiyonun hepsini dinliyorsun. Collectiona abonesin.

    // alttaki şekilde ise sadece id si belirli olan documente abonesin. Bir değişiklikte sadece doctaki datalar gelir.
    // var _userDocStream =
    //     await _firestore.doc('user/0nW9FNRHVvnGRdNfnLor').snapshots();
    // _userSubscribe = _userDocStream.listen(
    //   (event) {
    //     debugPrint(event
    //         .data()
    //         .toString()); //sadece ilgili doc döndüğünden for eacha ihtiyacın yok
    //   },
    // );
  }

  void batchKavrami() async {
    WriteBatch _batch = _firestore.batch();
    CollectionReference _counterColRef = _firestore.collection('counter');

/*
    for (int i = 0; i < 100; i++) {
      var _yeniDoc = _counterColRef.doc();
      _batch.set(_yeniDoc, {'sayac': ++i, 'id':_yeniDoc.id});
    }*/

/*
    var _counterDocs = await _counterColRef.get();
    _counterDocs.docs.forEach((element) {
      _batch.update(
          element.reference, {'createdAt': FieldValue.serverTimestamp()});
    });*/

    var _counterDocs = await _counterColRef.get();
    _counterDocs.docs.forEach((element) {
      _batch.delete(element.reference);
    });

    await _batch.commit();
  }

  void transactionKavrami() async {
    _firestore.runTransaction((transaction) async {
      //1emrenin bakiyesini öğren
      //emreden 100 lira düş
      //hasana 100 lira ekle
      DocumentReference<Map<String, dynamic>> emreRef =
          _firestore.doc('users/lODl1rILhnEeqeiDjBbj');
      DocumentReference<Map<String, dynamic>> hasanRef =
          _firestore.doc('users/UdpwK3unAKMMciZWUjKc');

      var _emreSnapshot = await transaction.get(emreRef);
      var _emreBakiye = _emreSnapshot.data()!['para'];
      if (_emreBakiye > 100) {
        var _yeniBakiye = _emreSnapshot.data()!['para'] - 100;
        transaction.update(emreRef, {'para': _yeniBakiye});
        transaction.update(hasanRef, {'para': FieldValue.increment(100)});
      }
    });
  }

  void imageUploadKameraGaleri() async {
    final ImagePicker _picker = ImagePicker();

    XFile? _file = await _picker.pickImage(source: ImageSource.camera);

    var _profileRef = await FirebaseStorage.instance.ref('users/profil_resmi');
    var _task = _profileRef.putFile(File(_file!.path));

    _task.whenComplete(() async {
      var _url = await _profileRef.getDownloadURL();
      _firestore
          .collection('users')
          .doc('0nW9FNRHVvnGRdNfnLor')
          .set({'profil resmi': _url}, SetOptions(merge: true));
    });
  }
}
