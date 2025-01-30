import 'package:bondgrid/constants/error_codes.dart';
import 'package:bondgrid/constants/error_message.dart';
import 'package:bondgrid/constants/storage_constants.dart';
import 'package:bondgrid/models/api_exception.dart';
import 'package:bondgrid/repo/authentication_repo.dart';
import 'package:bondgrid/services/storage_service.dart';
import 'package:bondgrid/services/token_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AuthenticationStateStatus {
  initial,
  loading,
  success,
  failure,
}

class AuthenticationState extends Equatable {
  final AuthenticationStateStatus status;
  final String errorMessage;

  const AuthenticationState(
      {this.status = AuthenticationStateStatus.initial,
      this.errorMessage = ""});

  @override
  List<Object?> get props => [status, errorMessage];
}

class FailureState extends AuthenticationState {
  const FailureState(String errorMessage)
      : super(
            status: AuthenticationStateStatus.failure,
            errorMessage: errorMessage);

  @override
  List<Object?> get props => [status, errorMessage];
}

// class InitialState extends AuthenticationState {}

// class LoadingState extends AuthenticationState {}

// class ErrorState extends AuthenticationState {
//   final String errorMessage;

//   ErrorState(this.errorMessage);
// }

class RegisterLoadingState extends AuthenticationState {
  const RegisterLoadingState()
      : super(status: AuthenticationStateStatus.loading);
}

class RegisterSuccessState extends AuthenticationState {
  final String token;

  const RegisterSuccessState(this.token)
      : super(status: AuthenticationStateStatus.success);
}

class VerifyEmailLoadingState extends AuthenticationState {
  const VerifyEmailLoadingState()
      : super(status: AuthenticationStateStatus.loading);
}

class VerifyEmailSuccessState extends AuthenticationState {
  final String token;

  const VerifyEmailSuccessState(this.token)
      : super(status: AuthenticationStateStatus.success);
}

class GeneratePhoneOTPLoadingState extends AuthenticationState {
  const GeneratePhoneOTPLoadingState()
      : super(status: AuthenticationStateStatus.loading);
}

class GeneratePhoneOTPSuccessState extends AuthenticationState {
  final String token;

  const GeneratePhoneOTPSuccessState(this.token)
      : super(status: AuthenticationStateStatus.success);
}

class VerifyPhoneOTPLoadingState extends AuthenticationState {
  const VerifyPhoneOTPLoadingState()
      : super(status: AuthenticationStateStatus.loading);
}

class VerifyPhoneOTPSuccessState extends AuthenticationState {
  final String token;

  const VerifyPhoneOTPSuccessState(this.token)
      : super(status: AuthenticationStateStatus.success);
}

class ResendOTPLoadingState extends AuthenticationState {
  const ResendOTPLoadingState()
      : super(status: AuthenticationStateStatus.loading);
}

class ResendOTPSuccessState extends AuthenticationState {
  const ResendOTPSuccessState()
      : super(status: AuthenticationStateStatus.success);
}

class HideTickState extends AuthenticationState {
  const HideTickState() : super(status: AuthenticationStateStatus.success);
}

class LoginLoadingState extends AuthenticationState {
  const LoginLoadingState() : super(status: AuthenticationStateStatus.loading);
}

class LoginSuccessState extends AuthenticationState {
  final String token;

  const LoginSuccessState(this.token)
      : super(status: AuthenticationStateStatus.success);
}

class LoginPhoneState extends AuthenticationState {
  final String token;

  const LoginPhoneState(this.token)
      : super(status: AuthenticationStateStatus.success);
}

class VerifyLoginLoadingState extends AuthenticationState {
  const VerifyLoginLoadingState()
      : super(status: AuthenticationStateStatus.loading);
}

class VerifyLoginSuccessState extends AuthenticationState {
  final String token;

  const VerifyLoginSuccessState(this.token)
      : super(status: AuthenticationStateStatus.success);
}

class ForgotPasswordLoadingState extends AuthenticationState {
  const ForgotPasswordLoadingState()
      : super(status: AuthenticationStateStatus.loading);
}

class ForgotPasswordSuccessState extends AuthenticationState {
  const ForgotPasswordSuccessState()
      : super(status: AuthenticationStateStatus.success);
}

class AuthenticationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class RegisterEvent extends AuthenticationEvent {
  final String firstName;
  final String middleName;
  final String lastName;
  final String email;
  final String password;

  RegisterEvent(this.firstName, this.middleName, this.lastName, this.email,
      this.password);
}

class VerifyEmailOTPEvent extends AuthenticationEvent {
  final String otp;

  VerifyEmailOTPEvent(this.otp);
}

class GeneratePhoneOTPEvent extends AuthenticationEvent {
  final String phoneNumber;

  GeneratePhoneOTPEvent(this.phoneNumber);
}

class VerifyPhoneOTPEvent extends AuthenticationEvent {
  final String otp;

  VerifyPhoneOTPEvent(this.otp);
}

class ResendOTPEvent extends AuthenticationEvent {
  ResendOTPEvent();
}

class LoginEvent extends AuthenticationEvent {
  final String email;
  final String password;

  LoginEvent(this.email, this.password);
}

class VerifyLoginOTPEvent extends AuthenticationEvent {
  final String otp;

  VerifyLoginOTPEvent(this.otp);
}

class ForgotPasswordEvent extends AuthenticationEvent {
  final String email;

  ForgotPasswordEvent(this.email);
}

extension on AuthenticationBloc {
  void _handleError(dynamic error, Emitter<AuthenticationState> emit) {
    if (error is ApiException) {
      switch (error.errorCode) {
        case ErrorCodes.USER_EXISTS:
          emit(const FailureState(
              "User already exists. Please login to continue."));
          break;
        case ErrorCodes.INVALID_USER:
          emit(const FailureState(
              "User not found. Please create an account to continue."));
          break;
        case ErrorCodes.INVALID_PASSWORD:
          emit(const FailureState(
              "Your email or password wasn't recognized. Please try again."));
          break;
        case ErrorCodes.INVALID_OTP:
          emit(
              const FailureState("Invalid OTP. Please enter the correct OTP."));
          break;
        case ErrorCodes.VALIDATION_FAILED:
          emit(FailureState(error.errorMessage));
          break;
        default:
          emit(FailureState(ErrorMessage.unexpectedErrorMessage));
          break;
      }
    } else {
      emit(FailureState(ErrorMessage.unexpectedErrorMessage));
    }
  }
}

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationRepo authenticationRepo;

  AuthenticationBloc(this.authenticationRepo)
      : super(const AuthenticationState()) {
    on<RegisterEvent>(((event, emit) async {
      emit(const RegisterLoadingState());
      // emit(
      //     const AuthenticationState(status: AuthenticationStateStatus.loading));
      try {
        final referralCodeData =
            await StorageService.getItem(StorageConstants.referralCode);
        String? referralCode;
        if (referralCodeData != null) {
          referralCode = referralCodeData["code"];
        }

        final response = await authenticationRepo.registerUser(event.firstName,
            event.middleName, event.lastName, event.email, event.password,
            referralCode: referralCode);

        final token = await TokenService.getTokenFromResponse(response);
        if (token != null) {
          await StorageService.storeItem(
              StorageConstants.jwtKey, {'token': token});

          final pushNotificationToken =
              await StorageService.getItem(StorageConstants.fcmToken);
          if (pushNotificationToken != null) {
            await authenticationRepo.addPushNotificationTokenAtRegistration(
                pushNotificationToken['token']);
          }
          emit(RegisterSuccessState(token));
        } else {
          emit(FailureState(ErrorMessage.unexpectedErrorMessage));
        }
      } catch (error) {
        _handleError(error, emit);
      }
    }));

    on<VerifyEmailOTPEvent>(((event, emit) async {
      emit(const VerifyEmailLoadingState());
      try {
        final response = await authenticationRepo.verifyEmailOTP(event.otp);
        final token = await TokenService.getTokenFromResponse(response);
        if (token != null) {
          await StorageService.storeItem(
              StorageConstants.jwtKey, {'token': token});
          emit(VerifyEmailSuccessState(token));
        } else {
          emit(FailureState(ErrorMessage.unexpectedErrorMessage));
        }
      } catch (error) {
        _handleError(error, emit);
      }
    }));

    on<GeneratePhoneOTPEvent>(((event, emit) async {
      emit(const GeneratePhoneOTPLoadingState());
      // emit(
      //     const AuthenticationState(status: AuthenticationStateStatus.loading));
      try {
        final response =
            await authenticationRepo.generatePhoneOTP(event.phoneNumber);
        final token = await TokenService.getTokenFromResponse(response);
        if (token != null) {
          await StorageService.storeItem(
              StorageConstants.jwtKey, {'token': token});
          emit(GeneratePhoneOTPSuccessState(token));
        } else {
          emit(FailureState(ErrorMessage.unexpectedErrorMessage));
        }
      } catch (error) {
        _handleError(error, emit);
      }
    }));

    on<VerifyPhoneOTPEvent>(((event, emit) async {
      emit(const VerifyPhoneOTPLoadingState());
      // emit(
      //     const AuthenticationState(status: AuthenticationStateStatus.loading));
      try {
        final response = await authenticationRepo.verifyPhoneOTP(event.otp);
        final token = await TokenService.getTokenFromResponse(response);
        if (token != null) {
          await StorageService.storeItem(
              StorageConstants.jwtKey, {'token': token});
          emit(VerifyPhoneOTPSuccessState(token));
        } else {
          emit(FailureState(ErrorMessage.unexpectedErrorMessage));
        }
      } catch (error) {
        _handleError(error, emit);
      }
    }));

    on<ResendOTPEvent>(((event, emit) async {
      emit(const ResendOTPLoadingState());
      // emit(
      //     const AuthenticationState(status: AuthenticationStateStatus.loading));
      try {
        await authenticationRepo.resendOTP();
        emit(const ResendOTPSuccessState());
        await Future.delayed(const Duration(seconds: 5));
        emit(const HideTickState());
      } catch (error) {
        _handleError(error, emit);
      }
    }));

    on<LoginEvent>(((event, emit) async {
      emit(const LoginLoadingState());
      // emit(
      //     const AuthenticationState(status: AuthenticationStateStatus.loading));
      try {
        final response =
            await authenticationRepo.login(event.email, event.password);
        final token = await TokenService.getTokenFromResponse(response);
        if (token != null) {
          await StorageService.storeItem(
              StorageConstants.jwtKey, {'token': token});
          // emit(LoginSuccessState(token));
          if (response['data'].containsKey('userStatus') &&
              response['data']['userStatus'] != null) {
            if (response['data']['userStatus'] == 'phone_verified') {
              emit(LoginSuccessState(token));
            } else {
              emit(LoginPhoneState(token));
            }
          }
        } else {
          emit(FailureState(ErrorMessage.unexpectedErrorMessage));
        }
      } catch (error) {
        _handleError(error, emit);
      }
    }));

    on<VerifyLoginOTPEvent>(((event, emit) async {
      emit(const VerifyLoginLoadingState());
      // emit(
      //     const AuthenticationState(status: AuthenticationStateStatus.loading));
      try {
        final response = await authenticationRepo.verifyLoginOTP(event.otp);
        final token = await TokenService.getTokenFromResponse(response);
        if (token != null) {
          await StorageService.storeItem(
              StorageConstants.jwtKey, {'token': token});
          final pushNotificationToken =
              await StorageService.getItem(StorageConstants.fcmToken);
          if (pushNotificationToken != null) {
            await authenticationRepo
                .addPushNotificationToken(pushNotificationToken['token']);
          }
          emit(VerifyLoginSuccessState(token));
        } else {
          emit(FailureState(ErrorMessage.unexpectedErrorMessage));
        }
      } catch (error) {
        _handleError(error, emit);
      }
    }));

    on<ForgotPasswordEvent>(((event, emit) async {
      emit(const ForgotPasswordLoadingState());
      // emit(
      //     const AuthenticationState(status: AuthenticationStateStatus.loading));
      try {
        await authenticationRepo.forgotPassword(event.email);
        emit(const ForgotPasswordSuccessState());
      } catch (error) {
        _handleError(error, emit);
      }
    }));
  }
}
