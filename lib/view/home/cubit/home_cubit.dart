import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/base/model/dio_exceptions.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/secret_constants.dart';
import '../../../core/extension/hashing_extension.dart';
import '../../../core/init/navigation/router.gr.dart';
import '../../../main.dart';
import '../../../view/detail/viewmodel/detail_viewmodel.dart';
import '../../../view/home/model/character_model.dart';
import '../../../view/home/service/home_service.dart';
import '../model/response_model.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeInitial());

  int offset = -30;

  int countOfCharacters = 1000;

  int limit = 30;

  bool _hasNext = true;

  bool get hasNext => _hasNext;

  final _characterMaps = [];
  final _characterFilterMaps = [];

  bool _isFetchingCharacters = false;

  List<CharacterModel> get characters => _characterMaps
      .map(
        (characterMap) => CharacterModel(
          id: characterMap['id'],
          name: characterMap['name'],
          description: characterMap['description'],
          photoURL: characterMap['thumbnail']['path'] +
              '/standard_xlarge.' +
              characterMap['thumbnail']['extension'],
        ),
      )
      .toList();

  List<CharacterModel> get characterFilter =>
      _characterFilterMaps.map((characterMap) => CharacterModel(
          id: characterMap.id,
          name: characterMap.name,
          description: characterMap.description,
          photoURL: characterMap.photoURL,
      )).toList();

  Future findNextCharacter(String searchTerm) async {
    if (_isFetchingCharacters) return;
    _isFetchingCharacters = true;

    _characterMaps.clear();

    _hasNext = true;

    var respConfig = configMode();
    CharacterResponseModel response;

    try {
      response = await HomeService.getFindCharacters(
          respConfig[0], respConfig[1]);

      _characterMaps.addAll(response.characterMapsList!);

     var characterFilters = characters
          .where((CharacterModel element){
            print(element.name);
            return element.name!.toLowerCase().contains(searchTerm.toLowerCase());
          }
     ).toList();
      print(characterFilters);
      _characterFilterMaps.clear();

      _characterFilterMaps.addAll(characterFilters);

      countOfCharacters = _characterFilterMaps.length;

      _hasNext = false;


      emit(HomeCompleted(characterFilter));
      emit(HomeFilter());
    } on DioError catch (e) {
      emit(HomeError(DioExceptions.fromDioError(e).message!));
    } catch (e) {
      rethrow;
    }
    _isFetchingCharacters = false;
  }

  Future fetchNextCharacters(BuildContext context) async {
    if (_isFetchingCharacters) return;
    _isFetchingCharacters = true;

    var respConfig = configMode();

    CharacterResponseModel response;
    try {
      offset += 30;

      response = await HomeService.getCharacters(
          respConfig[0], respConfig[1], offset, limit);

      _characterMaps.addAll(response.characterMapsList!);

      countOfCharacters = response.count!;

      if (response.characterMapsList!.length < limit) _hasNext = false;

      emit(HomeCompleted(characters));
    } on DioError catch (e) {
      emit(HomeError(DioExceptions.fromDioError(e).message!));
    } catch (e) {
      rethrow;
    }
    _isFetchingCharacters = false;
  }

  navigateToDetailView(CharacterModel character, DetailViewmodel viewmodel) {
    router.push(
      DetailRoute(characterModel: character, detailViewmodel: viewmodel),
    );
  }

  configMode() {
    int timeStamp = DateTime.now().millisecondsSinceEpoch;

    String input = timeStamp.toString() +
        SecretConstants.privateKey +
        AppConstants.publicKey;

    String hashCode = HashingExtension.generateMd5(input);

    return [timeStamp, hashCode];
  }
}
