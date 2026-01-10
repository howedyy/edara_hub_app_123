
abstract class AppException implements Exception {
  final String message;
  const AppException({required this.message});

}


class RemoteException extends AppException{
  const RemoteException({required super.message});
}

class LocalException extends AppException{
  const LocalException({required super.message});
}