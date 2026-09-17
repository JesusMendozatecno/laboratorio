import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'services/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initFirebase();
  runApp(const LaboratorioApp());
}

/// Inicializa Firebase con las opciones de la plataforma actual. Si aún no
/// se ha ejecutado `flutterfire configure`, se intenta con opciones por
/// defecto para no bloquear el arranque.
Future<void> _initFirebase() async {
  try {
    if (Firebase.apps.isEmpty) {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } catch (_) {
        await Firebase.initializeApp();
      }
    }
  } catch (e) {
    debugPrint('[Firebase] No se pudo inicializar: $e');
  }
}