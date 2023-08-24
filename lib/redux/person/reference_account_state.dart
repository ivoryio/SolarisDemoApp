import 'package:equatable/equatable.dart';
import 'package:solarisdemo/models/person/reference_account.dart';

abstract class ReferenceAccountState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ReferenceAccountInitialState extends ReferenceAccountState {}

class ReferenceAccountLoadingState extends ReferenceAccountState {
  ReferenceAccountLoadingState();
}

class ReferenceAccountFetchedState extends ReferenceAccountState {
  final ReferenceAccount referenceAccount;

  ReferenceAccountFetchedState(this.referenceAccount);

  @override
  List<Object?> get props => [referenceAccount];
}

class ReferenceAccountErrorState extends ReferenceAccountState {}
