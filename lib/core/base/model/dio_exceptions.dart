import 'package:dio/dio.dart';

class DioExceptions implements Exception {
  DioExceptions.fromDioError(DioError dioError) {
    switch (dioError.type) {
      case DioErrorType.cancel:
        message = "Se canceló la solicitud al servidor API";
        break;
      case DioErrorType.connectTimeout:
        message = "Tiempo de espera de conexión con el servidor API";
        break;
      case DioErrorType.other:
        message = "La conexión al servidor API falló debido a la conexión a Internet";
        break;
      case DioErrorType.receiveTimeout:
        message = "Tiempo de espera de recepción en conexión con el servidor API";
        break;
      case DioErrorType.response:
        message = _handleError(
            dioError.response!.statusCode!, dioError.response!.data);
        break;
      case DioErrorType.sendTimeout:
        message = "Enviar tiempo de espera en conexión con el servidor API";
        break;
      default:
        message = "Algo salio muy MAL =(";
        break;
    }
  }

  String? message;

  String _handleError(int statusCode, dynamic error) {
    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 401:
        return error['detail'];
      case 404:
        return error["message"];
      case 500:
        return 'Error en el servidor interno';
      default:
        return 'HUY! Algo salio mal';
    }
  }
}
