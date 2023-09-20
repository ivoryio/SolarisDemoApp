import 'package:solarisdemo/models/bank_card.dart';
import 'package:solarisdemo/services/api_service.dart';

class BankCardsService extends ApiService {
  BankCardsService({required super.user});

  Future<List<BankCard>?> getCards({
    BankCardsListFilter? filter,
  }) async {
    try {
      var data =
          await get('/account/cards', queryParameters: filter?.toMap() ?? {});

      List<BankCard>? cards =
          (data as List).map((card) => BankCard.fromJson(card)).toList();

      return cards;
    } catch (e) {
      throw Exception("Failed to load cards");
    }
  }


  Future<dynamic> createCard(CreateBankCard card) async {
    try {
      String path = '/account/cards';

      var data = await post(path, body: card.toJson());
      return data;
    } catch (e) {
      throw Exception("Failed to create card");
    }
  }

}

class BankCardsListFilter {
  final int? page;
  final int? size;

  BankCardsListFilter({
    this.page,
    this.size,
  });

  Map<String, String> toMap() {
    Map<String, String> map = {};

    if (page != null) {
      map["page[number]"] = page.toString();
    }

    if (size != null) {
      map["page[size]"] = size.toString();
    }

    return map;
  }
}
