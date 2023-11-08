import 'package:flutter_test/flutter_test.dart';
import 'package:solarisdemo/models/onboarding/onboarding_financial_details_attributes.dart';
import 'package:solarisdemo/models/onboarding/onboarding_financial_details_error_type.dart';
import 'package:solarisdemo/redux/onboarding/financial_details/onboarding_financial_details_action.dart';
import 'package:solarisdemo/redux/onboarding/financial_details/onboarding_financial_details_state.dart';

import '../../../setup/create_app_state.dart';
import '../../../setup/create_store.dart';
import 'onboarding_financial_details_mocks.dart';

void main() {
  const taxId = '123456789';
  test('when creating taxId it should display loaded state', () async {
    // given
    final store = createTestStore(
      onboardingFinancialDetailsService: FakeOnbordingFinancialDetailsService(),
      initialState: createAppState(
          onboardingFinancialDetailsState: const OnboardingFinancialDetailsState(
        financialDetailsAttributes: OnboardingFinancialDetailsAttributes(),
        isLoading: false,
      )),
    );

    final appState = store.onChange.firstWhere((state) => state.onboardingFinancialDetailsState.isLoading == true);

    // when
    store.dispatch(CreateTaxIdCommandAction(taxId: taxId));

    // then
    final financialDetailsState = (await appState).onboardingFinancialDetailsState;

    expect(financialDetailsState.isLoading, true);
  });

  test('when created taxId successful should update with success', () async {
    // given
    final store = createTestStore(
      onboardingFinancialDetailsService: FakeOnbordingFinancialDetailsService(),
      initialState: createAppState(
          onboardingFinancialDetailsState: const OnboardingFinancialDetailsState(
        financialDetailsAttributes: OnboardingFinancialDetailsAttributes(),
        isLoading: false,
      )),
    );

    final appState = store.onChange
        .firstWhere((state) => state.onboardingFinancialDetailsState.financialDetailsAttributes.taxId == taxId);

    // when
    store.dispatch(CreateTaxIdCommandAction(taxId: taxId));

    // then
    final financialDetailsState = (await appState).onboardingFinancialDetailsState;

    expect(financialDetailsState.isLoading, false);
    expect(financialDetailsState.errorType, null);
    expect(financialDetailsState.financialDetailsAttributes.taxId, taxId);
  });

  test('when created taxId failed should update with failure message', () async {
    // given
    final store = createTestStore(
      onboardingFinancialDetailsService: FakeFailingOnbordingFinancialDetailsService(),
      initialState: createAppState(
          onboardingFinancialDetailsState: const OnboardingFinancialDetailsState(
        financialDetailsAttributes: OnboardingFinancialDetailsAttributes(),
        isLoading: false,
      )),
    );

    final appState = store.onChange
        .firstWhere((state) => state.onboardingFinancialDetailsState.errorType == FinancialDetailsErrorType.taxId);

    // when
    store.dispatch(CreateTaxIdCommandAction(taxId: taxId));

    // then
    final financialDetailsState = (await appState).onboardingFinancialDetailsState;

    expect(financialDetailsState.isLoading, false);
    expect(financialDetailsState.errorType, FinancialDetailsErrorType.taxId);
    expect(financialDetailsState.financialDetailsAttributes.taxId, null);
  });

  test('when was received a failure message should send another taxId value and should goes in loading state',
      () async {
    // given
    final store = createTestStore(
      onboardingFinancialDetailsService: FakeOnbordingFinancialDetailsService(),
      initialState: createAppState(
          onboardingFinancialDetailsState: const OnboardingFinancialDetailsState(
        financialDetailsAttributes: OnboardingFinancialDetailsAttributes(),
        isLoading: false,
        errorType: FinancialDetailsErrorType.taxId,
      )),
    );

    final appState = store.onChange.firstWhere((state) => state.onboardingFinancialDetailsState.isLoading == true);

    // when
    store.dispatch(CreateTaxIdCommandAction(taxId: taxId));

    // then
    final financialDetailsState = (await appState).onboardingFinancialDetailsState;

    expect(financialDetailsState.isLoading, true);
    expect(financialDetailsState.financialDetailsAttributes.taxId, null);
  });
}
