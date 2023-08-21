import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:solarisdemo/config.dart';

import 'spaced_column.dart';
import '../utilities/format.dart';

const double defaultCardHorizontalPadding = 20;
const double defaultCardVerticalPadding = 15;
const double defaultHeigth = 202;
const double defaultWidth = 343;

class BankCardWidget extends StatelessWidget {
  final bool? isCardEmpty;
  final String? cardHolder;
  final String? cardNumber;
  final String? cardExpiry;
  final bool? isViewable;
  final String? cardType;
  final double? customHeight;
  final double? customWidth;

  const BankCardWidget({
    super.key,
    this.isCardEmpty = false,
    this.customHeight,
    this.customWidth,
    this.cardExpiry,
    this.cardHolder,
    this.cardNumber,
    this.isViewable = true,
    this.cardType,
  });

  @override
  Widget build(BuildContext context) {
    List<String> cardNumberParts = Format.iban(cardNumber ?? '').split(" ");

    return SizedBox(
      width: customWidth ?? defaultWidth,
      height: customHeight ?? defaultHeigth,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        margin: EdgeInsets.zero,
        color: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
              stops: [0.0, 1.0],
              colors: [
                Color(0xFF1D26A7),
                Color(0xFF6300BB),
              ],
              transform: GradientRotation(135 * (3.1415926 / 180.0)),
            ),
            image: DecorationImage(
              image:
                  AssetImage(ClientConfig.getAssetImagePath('card_logo.png')),
              fit: BoxFit.scaleDown,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: defaultCardVerticalPadding,
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(
                        left: defaultCardHorizontalPadding,
                      ),
                      child: VisaSvgIcon(),
                    ),
                    if (isViewable!) const EyeIcon(),
                    if (cardType != null) CardTypeLabel(cardType: cardType!),
                  ],
                ),
                if (isCardEmpty != true)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      defaultCardHorizontalPadding,
                      15,
                      defaultCardHorizontalPadding,
                      25,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ...cardNumberParts.map((cardNumberPart) {
                          Text textContent = Text(
                            cardNumberPart,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 24,
                              letterSpacing: 3,
                            ),
                          );
                          if (cardNumberPart == "****") {
                            return SizedBox(height: 20, child: textContent);
                          }

                          return textContent;
                        })
                      ],
                    ),
                  ),
                if (isCardEmpty != true)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SpacedColumn(
                          space: 3,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (cardHolder != null)
                              const Text(
                                "CARD HOLDER",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  height: 15 / 12,
                                ),
                              ),
                            Text(
                              cardHolder ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                height: 20 / 16,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          ],
                        ),
                        SpacedColumn(
                          space: 3,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (cardExpiry != null)
                              const Text(
                                "EXPIRES",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  height: 15 / 12,
                                ),
                              ),
                            Text(
                              cardExpiry ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                height: 20 / 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VisaSvgIcon extends StatelessWidget {
  const VisaSvgIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      "assets/icons/visa_pay_logo.svg",
      height: 40,
      width: 40,
      placeholderBuilder: (context) => const Text("VISA"),
    );
  }
}

class EyeIcon extends StatelessWidget {
  const EyeIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(right: 20),
      child: Icon(
        Icons.remove_red_eye_outlined,
        color: Colors.white,
        size: 25,
      ),
    );
  }
}

class CardTypeLabel extends StatelessWidget {
  final String cardType;

  const CardTypeLabel({
    super.key,
    required this.cardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(1000),
          bottomLeft: Radius.circular(1000),
        ),
      ),
      child: Text(
        cardType,
        style: const TextStyle(
          fontSize: 12,
          height: 18 / 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
