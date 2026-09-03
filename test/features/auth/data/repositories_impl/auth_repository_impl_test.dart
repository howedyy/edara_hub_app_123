import 'package:dartz/dartz.dart';
import 'package:edara_hub_app_123/core/errors/app_exception.dart';
import 'package:edara_hub_app_123/features/auth/data/data_sources/local/auth_local_data_source.dart';
import 'package:edara_hub_app_123/features/auth/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:edara_hub_app_123/features/auth/data/models/data.dart';
import 'package:edara_hub_app_123/features/auth/data/models/login_request.dart';
import 'package:edara_hub_app_123/features/auth/data/models/login_response.dart';
import 'package:edara_hub_app_123/features/auth/data/models/register_request.dart';
import 'package:edara_hub_app_123/features/auth/data/models/register_response.dart';
import 'package:edara_hub_app_123/features/auth/data/models/user.dart';
import 'package:edara_hub_app_123/features/auth/data/repositories_impl/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

class MockRemoteDataSource implements AuthRemoteDataSource {
  @override
  Future<LoginResponse> login(LoginRequest request) async {
    if (request.employeeId == 'valid') {
      return const LoginResponse(
        success: true,
        message: 'Success',
        data: Data(
          user: User(
            id: 1,
            name: 'Test',
            employeeId: 'valid',
            email: 'test@test.com',
            phone: '123456',
            ipDevice: '127.0.0.1',
            status: 'active',
          ),
          token: 'token',
        ),
      );
    } else {
      throw const RemoteException(message: 'Invalid credentials');
    }
  }

  @override
  Future<RegisterResponse> register(RegisterRequest request) => throw UnimplementedError();
}

class MockLocalDataSource implements AuthLocalDataSource {
  String? savedToken;
  @override
  Future<void> saveToken(String token) async {
    savedToken = token;
  }

  @override
  Future<String?> getToken() async => savedToken;
}

void main() {
  late AuthRepositoryImpl repository;
  late MockRemoteDataSource mockRemote;
  late MockLocalDataSource mockLocal;

  setUp(() {
    mockRemote = MockRemoteDataSource();
    mockLocal = MockLocalDataSource();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemote,
      localDataSource: mockLocal,
    );
  });

  test('should return Right(Data) and save token on successful login', () async {
    final result = await repository.login(const LoginRequest(employeeId: 'valid', password: 'password'));

    expect(result.isRight(), true);
    expect(mockLocal.savedToken, 'token');
  });

  test('should return Left(Failure) on failed login', () async {
    final result = await repository.login(const LoginRequest(employeeId: 'invalid', password: 'password'));

    expect(result.isLeft(), true);
    result.fold(
      (failure) => expect(failure.message, 'Invalid credentials'),
      (_) => fail('Should have returned Left'),
    );
  });
}
