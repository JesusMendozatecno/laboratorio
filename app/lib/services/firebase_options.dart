// ignore_for_file: type=lint
// ignore_for_file: dangling_library_doc_comments
//
// ARCHIVO GENERADO POR `flutterfire configure`.
//
// Ejecuta el siguiente comando para generar las credenciales reales de tu
// proyecto Firebase (reemplaza `tu_proyecto` por el ID de tu proyecto):
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure --project=tu_proyecto
//
// El CLI reescribirá este archivo automáticamente con la configuración de
// Android, iOS, Web y escritorio (Windows/macOS/Linux).

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Opciones de configuración por plataforma.
class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions no configurado para esta plataforma.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB5UcpuHdp3n55PJUIa77jzNs83Dy-aHnE',
    appId: '1:104090459139:android:5efd3f335d750199290236',
    messagingSenderId: '104090459139',
    projectId: 'laboratorio-unefa',
    storageBucket: 'laboratorio-unefa.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'TU_API_KEY_IOS',
    appId: 'TU_APP_ID_IOS',
    messagingSenderId: 'TU_SENDER_ID',
    projectId: 'tu-proyecto-id',
    storageBucket: 'tu-proyecto-id.appspot.com',
    iosBundleId: 'com.unefa.laboratorio.laboratorioApp',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD3ZvYVnD7imFObORVdXUoQUTMZ0J1-CA4',
    appId: '1:104090459139:web:09c9118eb112c225290236',
    messagingSenderId: '104090459139',
    projectId: 'laboratorio-unefa',
    authDomain: 'laboratorio-unefa.firebaseapp.com',
    storageBucket: 'laboratorio-unefa.firebasestorage.app',
    measurementId: 'G-69H322QW6Q',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD3ZvYVnD7imFObORVdXUoQUTMZ0J1-CA4',
    appId: '1:104090459139:web:8e680479b741ca07290236',
    messagingSenderId: '104090459139',
    projectId: 'laboratorio-unefa',
    authDomain: 'laboratorio-unefa.firebaseapp.com',
    storageBucket: 'laboratorio-unefa.firebasestorage.app',
    measurementId: 'G-WQBDVQDG7S',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'TU_API_KEY_MACOS',
    appId: 'TU_APP_ID_MACOS',
    messagingSenderId: 'TU_SENDER_ID',
    projectId: 'tu-proyecto-id',
    authDomain: 'tu-proyecto-id.firebaseapp.com',
    storageBucket: 'tu-proyecto-id.appspot.com',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'TU_API_KEY_LINUX',
    appId: 'TU_APP_ID_LINUX',
    messagingSenderId: 'TU_SENDER_ID',
    projectId: 'tu-proyecto-id',
    authDomain: 'tu-proyecto-id.firebaseapp.com',
    storageBucket: 'tu-proyecto-id.appspot.com',
  );
}
