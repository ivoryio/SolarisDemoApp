import 'package:solarisdemo/models/onboarding/onboarding_progress.dart';

class GetOnboardingProgressCommandAction {}

class OnboardingProgressFetchedEvendAction {
  final OnboardingStep step;

  OnboardingProgressFetchedEvendAction({required this.step});
}

class GetOnboardingProgressFailedEventAction {}
