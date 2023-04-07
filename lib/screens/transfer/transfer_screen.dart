import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solarisdemo/cubits/auth_cubit/auth_cubit.dart';
import 'package:solarisdemo/screens/home/modals/new_transfer_popup.dart';
import 'package:solarisdemo/themes/default_theme.dart';

import '../../widgets/platform_text_input.dart';
import '../../widgets/screen.dart';
import '../../cubits/transfer/transfer_cubit.dart';
import '../../widgets/spaced_column.dart';

class TransferScreen extends StatelessWidget {
  const TransferScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final person = context.read<AuthCubit>().state.user?.person;

    return BlocProvider.value(
      value: TransferCubit(),
      child: BlocBuilder<TransferCubit, TransferState>(
        builder: (context, state) {
          return Screen(
            title: "Transfer money",
            hideBottomNavbar: true,
            child: Padding(
              padding: defaultScreenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Send from",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Replace empty Row widget with a child widget
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: true //TO DO
                            ? Colors.black
                            : const Color(0xFFEAECF0),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 16,
                      ),
                      child: SpacedColumn(
                        space: 4,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: const Color(0xffE6E6E6),
                            ),
                            child: const Text("Main account",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                )),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                "Alexander-Matheus Braun",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  height: 20 / 16,
                                ),
                              ),
                              RadioButton(
                                checked: true,
                              )
                            ],
                          ),
                          const Text("DE84 1101 0101 4735 3658 36",
                              style: TextStyle(
                                fontSize: 14,
                                height: 17 / 14,
                                color: Color(0xff667085),
                              )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SpacedColumn(
                    space: 16,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Payee information",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      PlatformTextInput(
                        textLabel: "Name of the person/business",
                        hintText: "e.g Solaris",
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),
                      PlatformTextInput(
                        textLabel: "IBAN",
                        hintText: "e.g DE84 1101 0101 4735 3658 36",
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
