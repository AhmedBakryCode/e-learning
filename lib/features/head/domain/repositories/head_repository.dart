import 'dart:io';
import 'package:e_learning/features/head/domain/entities/head.dart';

abstract class HeadRepository {
  Future<List<Head>> getHeads();
  Future<void> createHead({
    required String title,
    required String name,
    required File image,
  });
  Future<void> updateHead({
    required String id,
    required String title,
    required String name,
    File? image,
  });
  Future<void> deleteHead(String id);
}
