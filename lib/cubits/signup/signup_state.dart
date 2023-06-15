part of 'signup_cubit.dart';

abstract class SignupState extends Equatable {
  final bool loading;
  final String? email;
  final String? phoneNumber;
  final String? firstName;
  final String? lastName;
  final String? passcode;
  final String? token;
  final String? personId;
  final User? user;

  const SignupState({
    this.user,
    this.personId,
    this.phoneNumber,
    this.loading = false,
    this.email,
    this.firstName,
    this.lastName,
    this.passcode,
    this.token,
  });

  @override
  List<Object> get props => [loading];
}

class SignupInitial extends SignupState {
  const SignupInitial() : super(loading: false);
}

class SignupLoading extends SignupState {
  const SignupLoading() : super(loading: true);
}

class SignupBasicInfoComplete extends SignupState {
  const SignupBasicInfoComplete({
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String passcode,
    required String personId,
  }) : super(
          email: email,
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
          passcode: passcode,
          personId: personId,
        );
}

class SignupEmailConfirmed extends SignupState {
  const SignupEmailConfirmed({
    required User user,
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String passcode,
  }) : super(
          email: email,
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
          passcode: passcode,
          user: user,
        );
}

class SignupMobileNumberConfirmed extends SignupState {
  const SignupMobileNumberConfirmed() : super();
}

class SignupGdprConsentComplete extends SignupState {
  const SignupGdprConsentComplete({
    required String personId,
    required String phoneNumber,
    required String passcode,
    required String email,
    required String firstName,
    required String lastName,
  }) : super(
            phoneNumber: phoneNumber,
            passcode: passcode,
            email: email,
            firstName: firstName,
            lastName: lastName,
            personId: personId);
}

class ConfirmedUser extends SignupState {
  const ConfirmedUser({
    required String phoneNumber,
    required String passcode,
    required String email,
    required String firstName,
    required String lastName,
  }) : super(
          phoneNumber: phoneNumber,
          passcode: passcode,
          email: email,
          firstName: firstName,
          lastName: lastName,
        );
}

class SignupError extends SignupState {
  final String message;

  const SignupError({
    super.email,
    super.phoneNumber,
    required this.message,
  });
}
