import 'package:flutter_test/flutter_test.dart';
import 'package:solarisdemo/models/user.dart';
import 'package:solarisdemo/redux/repayments/change_repayment/change_repayment_action.dart';
import 'package:solarisdemo/redux/repayments/change_repayment/change_repayment_state.dart';

import '../../../setup/create_store.dart';
import '../../../setup/create_app_state.dart';
import '../../../cubits/login_cubit_test.dart';
import 'change_repayment_mocks.dart';

void main() {
  User user = User(
    session: MockUserSession(),
    attributes: [],
    cognitoUser: MockCognitoUser(),
  );

  test('When asking to fetch card application the first time you enter the screen it should have a loading state',
      () async {
    //given
    final store = createTestStore(
      cardApplicationService: FakeCardApplicationService(),
      initialState: createAppState(
        cardApplicationState: CardApplicationInitialState(),
      ),
    );
    final appState = store.onChange.isEmpty;

    //when
    store.dispatch(GetCardApplicationCommandAction(user: user));

    //then
    expect(await appState, false);
  });

  test('When fetching minimum amount is failing should update with error', () async {
    //given
    final store = createTestStore(
      cardApplicationService: FakeFailingCardApplicationService(),
      initialState: createAppState(
        cardApplicationState: CardApplicationInitialState(),
      ),
    );
    final appState = store.onChange.firstWhere((element) => element.cardApplicationState is CardApplicationErrorState);

    //when
    store.dispatch(GetCardApplicationCommandAction(user: user));

    //then
    expect((await appState).cardApplicationState, isA<CardApplicationErrorState>());
  });

  test('When updating minimum amount is failing should update with error', () async {
    //given
    final store = createTestStore(
      cardApplicationService: FakeFailingCardApplicationService(),
      initialState: createAppState(
        cardApplicationState: CardApplicationInitialState(),
      ),
    );
    final appState = store.onChange.firstWhere((element) => element.cardApplicationState is CardApplicationErrorState);

    //when
    store.dispatch(UpdateCardApplicationCommandAction(
      user: user,
      fixedRate: 1000,
      percentageRate: 10,
      id: 'ff46c26e244f482a955ec0bb9a0170d4ccla',
    ));

    //then
    expect((await appState).cardApplicationState, isA<CardApplicationErrorState>());
  });

  test('When fetching minimum amount is successful should update with fetched data', () async {
    //given
    final store = createTestStore(
      cardApplicationService: FakeCardApplicationService(),
      initialState: createAppState(
        cardApplicationState: CardApplicationInitialState(),
      ),
    );
    final appState =
        store.onChange.firstWhere((element) => element.cardApplicationState is CardApplicationFetchedState);

    //when
    store.dispatch(GetCardApplicationCommandAction(user: user));

    //then
    expect((await appState).cardApplicationState, isA<CardApplicationFetchedState>());
  });
}
