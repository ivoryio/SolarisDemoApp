import 'dart:developer';

import 'api_service.dart';
import '../models/transfer.dart';
import '../utilities/format.dart';
import '../models/transaction_model.dart';
import '../models/authorization_request.dart';

class TransactionService extends ApiService {
  TransactionService({required super.user});

  Future<AuthorizationRequest> createTransfer(Transfer transfer) async {
    try {
      String path = 'transactions';

      var data = await post(path, body: transfer.toJson());

      return AuthorizationRequest.fromJson(data);
    } catch (e) {
      log(e.toString());
      throw Exception("Failed to create transfer");
    }
  }

  Future<List<Transaction>?> getTransactions({
    TransactionListFilter? filter,
  }) async {
    try {
      var data = await get(
        '/transactions',
        queryParameters: filter?.toMap() ?? {},
      );

      List<Transaction>? transactions = (data as List)
          .map((transaction) => Transaction.fromJson(transaction))
          .toList();

      return transactions;
    } catch (e) {
      throw Exception("Failed to load transactions");
    }
  }
}

class TransactionListFilter {
  final DateTime? bookingDateMin;
  final DateTime? bookingDateMax;
  final int? page;
  final int? size;
  final String? sort;

  const TransactionListFilter({
    this.bookingDateMin,
    this.bookingDateMax,
    this.page,
    this.size,
    this.sort,
  });

  Map<String, String> toMap() {
    Map<String, String> map = {};

    if (bookingDateMin != null) {
      map["filter[booking_date][min]"] = Format.date(bookingDateMin!);
    }

    if (bookingDateMax != null) {
      map["filter[booking_date][max]"] = Format.date(bookingDateMax!);
    }

    if (page != null) {
      map["page[number]"] = page.toString();
    }

    if (size != null) {
      map["page[size]"] = size.toString();
    }

    if (sort != null) {
      map["sort"] = sort!;
    }

    return map;
  }
}
