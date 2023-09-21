import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';
import 'package:solarisdemo/config.dart';
import 'package:solarisdemo/cubits/auth_cubit/auth_cubit.dart';
import 'package:solarisdemo/infrastructure/bank_card/bank_card_presenter.dart';
import 'package:solarisdemo/models/user.dart';
import 'package:solarisdemo/redux/app_state.dart';
import 'package:solarisdemo/redux/bank_card/bank_card_action.dart';
import 'package:solarisdemo/screens/wallet/change_pin/card_change_pin_confirm_screen.dart';
import 'package:solarisdemo/widgets/app_toolbar.dart';
import 'package:solarisdemo/widgets/screen_scaffold.dart';

class BankCardChangePinChooseScreen extends StatelessWidget {
  static const routeName = "/bankCardChangePinChooseScreen";

  const BankCardChangePinChooseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().state.user!;
    final GlobalKey<_ChangePinBodyState> _changePinBodyKey = GlobalKey<_ChangePinBodyState>();
    ValueNotifier<bool> birthdayErrorNotifier = ValueNotifier<bool>(false);
    ValueNotifier<bool> postalCodeErrorNotifier = ValueNotifier<bool>(false);
    ValueNotifier<bool> sequenceErrorNotifier = ValueNotifier<bool>(false);
    ValueNotifier<bool> repeatingErrorNotifier = ValueNotifier<bool>(false);

    return StoreConnector<AppState, BankCardViewModel>(
      onDidChange: (previousViewModel, viewModel) {
        if (previousViewModel is BankCardFetchedViewModel && viewModel is BankCardPinChoosenViewModel) {
          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.pushNamed(
              context,
              BankCardConfirmPinConfirmScreen.routeName,
            );
          });
        }
      },
      onWillChange: (previousViewModel, newViewModel) {
        if (previousViewModel is BankCardLoadingViewModel && newViewModel is BankCardFetchedViewModel) {
          _changePinBodyKey.currentState?.clearPinAndResetFocus();
        }
      },
      converter: (store) {
        return BankCardPresenter.presentBankCard(
          bankCardState: store.state.bankCardState,
          user: user,
        );
      },
      builder: (context, viewModel) {
        return ScreenScaffold(
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: AppToolbar(
                  onBackButtonPressed: () {
                    Navigator.pop(context);
                    StoreProvider.of<AppState>(context).dispatch(
                      GetBankCardCommandAction(
                        user: user,
                        cardId: viewModel.bankCard!.id,
                      ),
                    );
                  },
                  richTextTitle: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Step 1',
                          style: ClientConfig.getTextStyleScheme().heading4,
                        ),
                        TextSpan(
                          text: " out of 2",
                          style: ClientConfig.getTextStyleScheme().heading4.copyWith(color: const Color(0xFF56555E)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: LinearProgressIndicator(
                  value: 0.05,
                  color: ClientConfig.getColorScheme().secondary,
                  backgroundColor: const Color(0xFFADADB4),
                ),
              ),
              ChangePinBody(
                key: _changePinBodyKey,
                viewModel: viewModel,
                birthdayErrorNotifier: birthdayErrorNotifier,
                postalCodeErrorNotifier: postalCodeErrorNotifier,
                sequenceErrorNotifier: sequenceErrorNotifier,
                repeatingErrorNotifier: repeatingErrorNotifier,
              ),
              const Spacer(),
              if (viewModel is! BankCardPinChoosenViewModel)
                ChangePinChecks(
                  viewModel: viewModel,
                  birthdayErrorNotifier: birthdayErrorNotifier,
                  postalCodeErrorNotifier: postalCodeErrorNotifier,
                  sequenceErrorNotifier: sequenceErrorNotifier,
                  repeatingErrorNotifier: repeatingErrorNotifier,
                ),
            ],
          ),
        );
      },
    );
  }
}

class ChangePinBody extends StatefulWidget {
  final BankCardViewModel viewModel;
  final ValueNotifier<bool> birthdayErrorNotifier;
  final ValueNotifier<bool> postalCodeErrorNotifier;
  final ValueNotifier<bool> sequenceErrorNotifier;
  final ValueNotifier<bool> repeatingErrorNotifier;

  const ChangePinBody({
    Key? key,
    required this.viewModel,
    required this.birthdayErrorNotifier,
    required this.postalCodeErrorNotifier,
    required this.sequenceErrorNotifier,
    required this.repeatingErrorNotifier,
  }) : super(key: key);

  @override
  State<ChangePinBody> createState() => _ChangePinBodyState();
}

class _ChangePinBodyState extends State<ChangePinBody> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusPin = FocusNode();
  String _newPIN = '';
  bool hasError = false;

  bool hasConsecutiveDigits(String pin) {
    if (pin.length < 4) {
      widget.sequenceErrorNotifier.value = false;
      widget.repeatingErrorNotifier.value = false;
      return true;
    }

    for (int i = 0; i < pin.length - 3; i++) {
      int digit1 = int.parse(pin[i]);
      int digit2 = int.parse(pin[i + 1]);
      int digit3 = int.parse(pin[i + 2]);
      int digit4 = int.parse(pin[i + 3]);

      if ((digit2 == digit1 + 1 && digit3 == digit2 + 1 && digit4 == digit3 + 1) ||
          (digit2 == digit1 - 1 && digit3 == digit2 - 1 && digit4 == digit3 - 1)) {
        widget.sequenceErrorNotifier.value = true;
        widget.repeatingErrorNotifier.value = false;
        return false;
      }
    }

    widget.sequenceErrorNotifier.value = false;
    widget.repeatingErrorNotifier.value = false;
    return true;
  }

  bool hasRepeatingDigits(String pin) {
    if (pin.length < 4) {
      widget.repeatingErrorNotifier.value = false;
      widget.sequenceErrorNotifier.value = false;
      return true;
    }

    Map<String, int> digitCount = {};

    for (int i = 0; i < pin.length; i++) {
      String digit = pin[i];
      digitCount[digit] = (digitCount[digit] ?? 0) + 1;
    }

    for (var value in digitCount.values) {
      if (value > 2) {
        widget.repeatingErrorNotifier.value = true;
        widget.sequenceErrorNotifier.value = false;
        return false;
      }
    }

    widget.repeatingErrorNotifier.value = false;
    widget.sequenceErrorNotifier.value = false;
    return true;
  }

  bool containsPostalCode(String pin, String postalCode) {
    if (pin.length < 4) {
      widget.postalCodeErrorNotifier.value = false;
      return true;
    }
    if (postalCode.contains(_newPIN)) {
      widget.postalCodeErrorNotifier.value = true;
      return false;
    }
    widget.postalCodeErrorNotifier.value = false;
    return true;
  }

  bool containsBirthDate(String pin, DateTime birtDate) {
    if (pin.length < 4) {
      widget.birthdayErrorNotifier.value = false;
      return true;
    }
    String formattedDate = DateFormat('yyyyMMdd').format(birtDate);

    if (formattedDate.contains(_newPIN)) {
      widget.birthdayErrorNotifier.value = true;
      return false;
    }
    widget.birthdayErrorNotifier.value = false;
    return true;
  }

  void resetErrorNotifiers() {
    setState(
      () {
        hasError = false;
      },
    );
    widget.birthdayErrorNotifier.value = false;
    widget.postalCodeErrorNotifier.value = false;
    widget.sequenceErrorNotifier.value = false;
    widget.repeatingErrorNotifier.value = false;
  }

  void clearPinAndResetFocus() {
    setState(() {
      _newPIN = '';
      _controller.clear();
      _focusPin.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    AuthenticatedUser user = context.read<AuthCubit>().state.user!;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Choose PIN",
            style: ClientConfig.getTextStyleScheme().heading2,
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            "Remember your PIN as you will use it for all future card purchases.",
            style: ClientConfig.getTextStyleScheme().bodyLargeRegular,
          ),
          const SizedBox(
            height: 32,
          ),
          GestureDetector(
            onTap: () {
              _focusPin.requestFocus();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                4,
                (index) {
                  return Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: hasError
                          ? const Color(0xffE61F27)
                          : widget.viewModel is BankCardPinChoosenViewModel
                              ? const Color(0xff00774C)
                              : index >= _newPIN.length
                                  ? const Color(0xffadadb4)
                                  : const Color(0xff15141E),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 1,
            child: TextField(
              autofocus: true,
              controller: _controller,
              focusNode: _focusPin,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              keyboardType: TextInputType.number,
              decoration: const InputDecoration.collapsed(
                hintText: 'PIN',
              ),
              style: TextStyle(
                color: Colors.grey.withOpacity(0),
              ),
              cursorColor: Colors.transparent,
              cursorRadius: const Radius.circular(0),
              cursorWidth: 0,
              onChanged: (text) {
                if (text.length <= 4) {
                  setState(
                    () {
                      _newPIN = text;
                      hasError = !hasConsecutiveDigits(_newPIN) ||
                          !containsPostalCode(_newPIN, user.person.address?.postalCode ?? 'postalCode') ||
                          !hasRepeatingDigits(_newPIN) ||
                          !containsBirthDate(_newPIN, user.person.birthDate ?? DateTime.now());

                      if (hasError && text.length == 4) {
                        Future.delayed(
                          const Duration(seconds: 2),
                          () {
                            resetErrorNotifiers();
                            clearPinAndResetFocus();
                          },
                        );
                      } else if (!hasError && text.length == 4) {
                        _focusPin.unfocus();
                        StoreProvider.of<AppState>(context).dispatch(
                          BankCardChoosePinCommandAction(
                            pin: _newPIN,
                            user: user,
                            bankCard: widget.viewModel.bankCard!,
                          ),
                        );
                      }
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ChangePinChecks extends StatelessWidget {
  final BankCardViewModel viewModel;
  final ValueNotifier<bool> birthdayErrorNotifier;
  final ValueNotifier<bool> postalCodeErrorNotifier;
  final ValueNotifier<bool> sequenceErrorNotifier;
  final ValueNotifier<bool> repeatingErrorNotifier;

  const ChangePinChecks({
    Key? key,
    required this.viewModel,
    required this.birthdayErrorNotifier,
    required this.postalCodeErrorNotifier,
    required this.sequenceErrorNotifier,
    required this.repeatingErrorNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your PIN should not contain:",
            style: ClientConfig.getTextStyleScheme().bodyLargeRegularBold,
          ),
          const SizedBox(
            height: 8,
          ),
          ValueListenableBuilder<bool>(
              valueListenable: birthdayErrorNotifier,
              builder: (context, hasError, child) {
                return Row(
                  children: [
                    Icon(
                      Icons.close,
                      size: 24,
                      color: birthdayErrorNotifier.value ? const Color(0xffE61F27) : const Color(0xFF56555E),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      "Your date of birth",
                      style: ClientConfig.getTextStyleScheme().bodyLargeRegular.copyWith(
                          color: birthdayErrorNotifier.value ? const Color(0xffE61F27) : const Color(0xFF56555E)),
                    ),
                  ],
                );
              }),
          ValueListenableBuilder<bool>(
              valueListenable: postalCodeErrorNotifier,
              builder: (context, hasError, child) {
                return Row(
                  children: [
                    Icon(
                      Icons.close,
                      size: 24,
                      color: postalCodeErrorNotifier.value ? const Color(0xffE61F27) : const Color(0xFF56555E),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      "Your postal code",
                      style: ClientConfig.getTextStyleScheme().bodyLargeRegular.copyWith(
                          color: postalCodeErrorNotifier.value ? const Color(0xffE61F27) : const Color(0xFF56555E)),
                    ),
                  ],
                );
              }),
          ValueListenableBuilder<bool>(
              valueListenable: sequenceErrorNotifier,
              builder: (context, hasError, child) {
                return Row(
                  children: [
                    Icon(
                      Icons.close,
                      size: 24,
                      color: sequenceErrorNotifier.value ? const Color(0xffE61F27) : const Color(0xFF56555E),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      "Number sequences, e.g. 1234",
                      style: ClientConfig.getTextStyleScheme().bodyLargeRegular.copyWith(
                          color: sequenceErrorNotifier.value ? const Color(0xffE61F27) : const Color(0xFF56555E)),
                    ),
                  ],
                );
              }),
          ValueListenableBuilder<bool>(
              valueListenable: repeatingErrorNotifier,
              builder: (context, hasError, child) {
                return Row(
                  children: [
                    Icon(
                      Icons.close,
                      size: 24,
                      color: repeatingErrorNotifier.value ? const Color(0xffE61F27) : const Color(0xFF56555E),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      "More than two digits repeating",
                      style: ClientConfig.getTextStyleScheme().bodyLargeRegular.copyWith(
                          color: repeatingErrorNotifier.value ? const Color(0xffE61F27) : const Color(0xFF56555E)),
                    ),
                  ],
                );
              }),
        ],
      ),
    );
  }
}
