import 'package:chronicle/features/auth/domain/model/user_model.dart';
import 'package:equatable/equatable.dart';

enum UserStatus {
  initial,
  loading,
  success,
  error,logout
}

class UserState extends Equatable{
  final UserStatus status;
  final String? errorMessage;

  final UserModel? userModel;

  const UserState._({
    required this.status,
    this.errorMessage,
    this.userModel,
  });

  factory UserState.initial() => UserState._(status: UserStatus.initial);

  UserState copyWith(
      {UserStatus? status, String? errorMessage, UserModel? userModel}) {
    return UserState._(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      userModel: userModel ?? this.userModel,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, userModel];
}
