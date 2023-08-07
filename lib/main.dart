import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:redux/redux.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:solarisdemo/infrastructure/transactions/transaction_service.dart';
import 'package:solarisdemo/ivory_app.dart';
import 'package:solarisdemo/redux/app_state.dart';
import 'package:solarisdemo/redux/store_factory.dart';

import '../config.dart';

Future<void> main() async {
  await dotenv.load();
  ClientConfigData clientConfig = ClientConfig.getClientConfig();

  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  final store = _buildStore();

  runApp(IvoryApp(clientConfig: clientConfig, store: store,));
}

Store<AppState> _buildStore(){
  final store = createStore(
      initialState: AppState.initialState(),
      transactionService: TransactionService(),
  );

  return store;
}
