import 'package:redux/redux.dart';
import 'package:solarisdemo/infrastructure/onboarding/identity_verification/onboarding_identity_verification_service.dart';
import 'package:solarisdemo/models/onboarding/onboarding_identity_verification_error_type.dart';
import 'package:solarisdemo/redux/app_state.dart';
import 'package:solarisdemo/redux/auth/auth_state.dart';
import 'package:solarisdemo/redux/documents/documents_action.dart';
import 'package:solarisdemo/redux/onboarding/identity_verification/onboarding_identity_verification_action.dart';
import 'package:solarisdemo/utilities/retry.dart';

class OnboardingIdentityVerificationMiddleware extends MiddlewareClass<AppState> {
  final OnbordingIdentityVerificationService _onboardingIdentityVerificationService;

  OnboardingIdentityVerificationMiddleware(this._onboardingIdentityVerificationService);

  @override
  call(Store<AppState> store, dynamic action, NextDispatcher next) async {
    next(action);

    final authState = store.state.authState;
    if (authState is! AuthenticationInitializedState) {
      return;
    }

    if (action is CreateIdentificationCommandAction) {
      store.dispatch(OnboardingIdentityVerificationLoadingEventAction());

      final response = await _onboardingIdentityVerificationService.createIdentification(
        user: authState.cognitoUser,
        accountName: action.accountName,
        iban: action.iban,
        termsAndCondsSignedAt: DateTime.now().toUtc().toIso8601String(),
      );

      if (response is CreateIdentificationSuccessResponse) {
        store.dispatch(CreateIdentificationSuccessEventAction(urlForIntegration: response.urlForIntegration));
      } else if (response is IdentityVerificationServiceErrorResponse) {
        store.dispatch(OnboardingIdentityVerificationErrorEventAction(errorType: response.errorType));
      }
    }

    if (action is GetSignupIdentificationInfoCommandAction) {
      store.dispatch(OnboardingIdentityVerificationLoadingEventAction());

      await Future.delayed(const Duration(milliseconds: 500));

      final response = await retry(
        () => _onboardingIdentityVerificationService.getSignupIdentificationInfo(user: authState.cognitoUser),
        retryIf: (response) =>
            response is IdentityVerificationServiceErrorResponse &&
            response.errorType == OnboardingIdentityVerificationErrorType.pendingIdentification,
      );

      if (response is GetSignupIdentificationInfoSuccessResponse) {
        store.dispatch(SignupIdentificationInfoFetchedEventAction(identificationStatus: response.identificationStatus));
        store.dispatch(DocumentsFetchedEventAction(documents: response.documents));
      } else if (response is IdentityVerificationServiceErrorResponse) {
        store.dispatch(OnboardingIdentityVerificationErrorEventAction(errorType: response.errorType));
      }
    }

    if (action is AuthorizeIdentificationSigningCommandAction) {
      store.dispatch(OnboardingIdentityAuthorizationLoadingEventAction());

      final response = await _onboardingIdentityVerificationService.authorizeIdentification(
        user: authState.cognitoUser,
      );

      if (response is AuthorizeIdentificationSuccessResponse) {
        store.dispatch(AuthorizeIdentificationSigningSuccessEventAction());
      } else if (response is IdentityVerificationServiceErrorResponse) {
        store.dispatch(OnboardingIdentityVerificationErrorEventAction(errorType: response.errorType));
      }
    }
  }
}
