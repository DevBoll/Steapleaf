import '../models/tea.dart';

abstract interface class TeaRepository {
  Future<List<Tea>> getAll();
  Future<Tea?> getById(String id);
  Future<void> save(Tea tea);
  Future<void> update(Tea tea);
  Future<void> delete(String id);
}
