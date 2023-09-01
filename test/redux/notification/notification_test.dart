import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solarisdemo/models/notifications/notification_transaction_message.dart';
import 'package:solarisdemo/redux/notification/notification_action.dart';
import 'package:solarisdemo/redux/notification/notification_state.dart';
import 'package:solarisdemo/redux/transactions/approval/transaction_approval_state.dart';

import '../../infrastructure/bank_card/bank_card_presenter_test.dart';
import '../../setup/create_app_state.dart';
import '../../setup/create_store.dart';
import '../transactions/transactions_mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  SharedPreferences.setMockInitialValues({});

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('com.thinslices.solarisdemo/native'),
    (call) async {
      return '';
    },
  );

  const message = NotificationTransactionMessage(
    changeRequestId: "changeRequestId",
    declineChangeRequestId: "declineChangeRequestId",
    amountCurrency: "EUR",
    amountUnit: "cents",
    amountValue: "32",
    merchantName: "KFC",
  );

  test("When received a transaction approval notification the states should change accordingly", () async {
    // given
    final store = createTestStore(
      changeRequestService: FakeChangeRequestService(),
      initialState: createAppState(
        notificationState: NotificationInitialState(),
        transactionApprovalState: TransactionApprovalInitialState(),
      ),
    );
    final appState = store.onChange.firstWhere(
      (element) => element.notificationState is NotificationTransactionApprovalState,
    );
    final transactionApprovalState = store.onChange.firstWhere(
      (element) => element.transactionApprovalState is TransactionApprovalLoadingState,
    );

    // when
    store.dispatch(ReceivedTransactionApprovalNotificationEventAction(user: MockUser(), message: message));

    // then
    expect((await appState).notificationState, isA<NotificationTransactionApprovalState>());
    expect((await transactionApprovalState).transactionApprovalState, isA<TransactionApprovalLoadingState>());
  });

  test("When using the reset command the state should reset to initial", () async {
    // given
    final store = createTestStore(
      initialState: createAppState(
        notificationState: NotificationTransactionApprovalState(message: message),
      ),
    );
    final appState = store.onChange.firstWhere(
      (element) => element.notificationState is NotificationInitialState,
    );

    // when
    store.dispatch(ResetNotificationCommandAction());

    // then
    expect((await appState).notificationState, isA<NotificationInitialState>());
  });
}
