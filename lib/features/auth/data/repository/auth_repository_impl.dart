import 'package:chronicle/core/failure/failure.dart';
import 'package:chronicle/core/model/either.dart';
import 'package:chronicle/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:chronicle/features/auth/domain/model/user_model.dart';
import 'package:chronicle/features/auth/domain/repository/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;

  AuthRepositoryImpl({required this.authRemoteDataSource});

  @override
  Future<Either<Failure, UserModel>> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final firebaseCredentials =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final firebaseToken = await firebaseCredentials.user?.getIdToken();

      final request =
          await authRemoteDataSource.loginWithGoogle(firebaseToken!);

      return Either.right(request);
    } on DioException catch (e) {
      return Either.left(AuthFailure(message: e.response?.data['error']));
    } on Exception catch (e) {
      return Either.left(AuthFailure(message: "Authentication failure!"));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      FirebaseAuth.instance.signOut();
      return Either.right(0);
    } catch (e) {
      return Either.left(AuthFailure(message: "Logout failure!"));
    }
  }
}
