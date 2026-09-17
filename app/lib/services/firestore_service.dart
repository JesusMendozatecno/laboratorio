import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';

/// Abstracción sobre Cloud Firestore.
class FirestoreService {
  FirestoreService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  // ===========================
  // USUARIOS
  // ===========================

  Future<void> saveUser(AppUser user) {
    return _db
        .collection('usuarios')
        .doc(user.uid)
        .set(user.toFirestore());
  }

  Future<AppUser?> getUserByUid(String uid) async {
    final doc = await _db.collection('usuarios').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc.data()!);
  }

  /// Busca un usuario por su cédula. Útil para iniciar sesión con cédula
  /// en lugar de correo (compatibilidad con el sistema web original).
  Future<AppUser?> getUserByCedula(String cedula) async {
    final query = await _db
        .collection('usuarios')
        .where('cedula', isEqualTo: cedula)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    return AppUser.fromFirestore(query.docs.first.data());
  }

  // ===========================
  // GENÉRICO (CRUD base)
  // ===========================

  Future<void> add(String collection, Map<String, dynamic> data) {
    return _db.collection(collection).add(data);
  }

  Future<void> update(String collection, String id, Map<String, dynamic> data) {
    return _db.collection(collection).doc(id).update(data);
  }

  Future<void> delete(String collection, String id) {
    return _db.collection(collection).doc(id).delete();
  }

  /// Lectura puntual de todos los documentos de una colección.
  Future<List<Map<String, dynamic>>> getAll(
    String collection, {
    List<QueryFilter>? filters,
  }) async {
    Query<Map<String, dynamic>> query = _db.collection(collection);
    filters?.forEach((f) {
      query = query.where(f.field, isEqualTo: f.value);
    });
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watch(String collection,
      {List<QueryFilter>? filters, String? orderBy, bool descending = false}) {
    Query<Map<String, dynamic>> query = _db.collection(collection);
    filters?.forEach((f) {
      query = query.where(f.field, isEqualTo: f.value);
    });
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }
    return query.snapshots();
  }
}

/// Filtro de consulta para Firestore.
class QueryFilter {
  const QueryFilter(this.field, this.value);

  final String field;
  final Object? value;
}