import '../models/session.dart';

abstract interface class SessionRepository {
  Future<List<Session>> getAll();
  Future<void> save(Session session);
  Future<void> update(Session session);
  Future<void> delete(String id);
}
