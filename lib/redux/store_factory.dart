import 'package:redux/redux.dart';
import 'package:solarisdemo/infrastructure/credit_line/credit_line_middleware.dart';
import 'package:solarisdemo/infrastructure/credit_line/credit_line_service.dart';
import 'package:solarisdemo/infrastructure/notifications/notifications_middleware.dart';
import 'package:solarisdemo/infrastructure/notifications/push_notification_service.dart';
import 'package:solarisdemo/infrastructure/transactions/transaction_middleware.dart';
import 'package:solarisdemo/infrastructure/transactions/transaction_service.dart';
import 'package:solarisdemo/redux/app_reducer.dart';

import 'app_state.dart';

Store<AppState> createStore({
  required AppState initialState,
  required TransactionService transactionService,
  required CreditLineService creditLineService,
  required PushNotificationService pushNotificationService,
}) {
  return Store<AppState>(
    appReducer,
    initialState: initialState,
    middleware: [
      GetTransactionsMiddleware(transactionService),
      GetCreditLineMiddleware(creditLineService),
      NotificationsMiddleware(pushNotificationService),
    ],
  );
}
