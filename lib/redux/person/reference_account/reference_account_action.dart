import 'package:solarisdemo/models/person/person_reference_account.dart';
import 'package:solarisdemo/models/person/person_service_error_type.dart';
import 'package:solarisdemo/models/user.dart';

class GetReferenceAccountCommandAction {
  final User user;

  GetReferenceAccountCommandAction({required this.user});
}

class ReferenceAccountLoadingEventAction {}

class ReferenceAccountFetchedEventAction {
  final PersonReferenceAccount referenceAccount;

  ReferenceAccountFetchedEventAction(this.referenceAccount);
}

class GetReferenceAccountFailedEventAction {
  PersonServiceErrorType errorType;

  GetReferenceAccountFailedEventAction({this.errorType = PersonServiceErrorType.unknown});
}
