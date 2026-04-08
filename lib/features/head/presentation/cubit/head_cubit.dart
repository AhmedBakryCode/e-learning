import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_learning/features/head/domain/entities/head.dart';
import 'package:e_learning/features/head/domain/usecases/get_head_usecase.dart';
import 'package:e_learning/features/head/domain/usecases/update_head_usecase.dart';
import 'package:e_learning/features/head/domain/usecases/create_head_usecase.dart';
import 'package:e_learning/features/head/domain/usecases/delete_head_usecase.dart';

abstract class HeadState extends Equatable {
  const HeadState();
  @override
  List<Object?> get props => [];
}

class HeadInitial extends HeadState {}
class HeadLoading extends HeadState {}
class HeadLoaded extends HeadState {
  final List<Head> heads;
  const HeadLoaded(this.heads);
  @override
  List<Object?> get props => [heads];
}
class HeadError extends HeadState {
  final String message;
  const HeadError(this.message);
  @override
  List<Object?> get props => [message];
}

class HeadCubit extends Cubit<HeadState> {
  final GetHeadUseCase getHeadUseCase;
  final CreateHeadUseCase createHeadUseCase;
  final UpdateHeadUseCase updateHeadUseCase;
  final DeleteHeadUseCase deleteHeadUseCase;

  HeadCubit({
    required this.getHeadUseCase,
    required this.createHeadUseCase,
    required this.updateHeadUseCase,
    required this.deleteHeadUseCase,
  }) : super(HeadInitial());

  Future<void> fetchHeads() async {
    emit(HeadLoading());
    try {
      final heads = await getHeadUseCase();
      emit(HeadLoaded(heads));
    } catch (e) {
      emit(HeadError(e.toString()));
    }
  }

  Future<void> createHead({
    required String title,
    required String name,
    required File image,
  }) async {
    emit(HeadLoading());
    try {
      await createHeadUseCase(title: title, name: name, image: image);
      await fetchHeads();
    } catch (e) {
      emit(HeadError(e.toString()));
    }
  }

  Future<void> updateHead({
    required String id,
    required String title,
    required String name,
    File? image,
  }) async {
    emit(HeadLoading());
    try {
      await updateHeadUseCase(id: id, title: title, name: name, image: image);
      await fetchHeads();
    } catch (e) {
      emit(HeadError(e.toString()));
    }
  }

  Future<void> deleteHead(String id) async {
    emit(HeadLoading());
    try {
      await deleteHeadUseCase(id);
      await fetchHeads();
    } catch (e) {
      emit(HeadError(e.toString()));
    }
  }
}
