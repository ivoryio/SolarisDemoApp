import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solarisdemo/config.dart';
import 'package:solarisdemo/cubits/auth_cubit/auth_cubit.dart';
import 'package:solarisdemo/models/amount_value.dart';
import 'package:solarisdemo/models/categories/category.dart';
import 'package:solarisdemo/models/transactions/transaction_model.dart';
import 'package:solarisdemo/models/transactions/upcoming_transaction_model.dart';
import 'package:solarisdemo/screens/repayments/repayments_screen.dart';
import 'package:solarisdemo/screens/splitpay/splitpay_screen.dart';
import 'package:solarisdemo/utilities/format.dart';
import 'package:solarisdemo/widgets/app_toolbar.dart';
import 'package:solarisdemo/widgets/expanded_details_row.dart';
import 'package:solarisdemo/widgets/ivory_list_tile.dart';
import 'package:solarisdemo/widgets/screen_scaffold.dart';
import 'package:solarisdemo/widgets/spaced_column.dart';

class TransactionDetailScreen extends StatelessWidget {
  static const routeName = "/transactionDetailScreen";

  const TransactionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final argument = ModalRoute.of(context)!.settings.arguments;
    final user = context.read<AuthCubit>().state.user!;

    AmountValue amountValue;
    IconData mainIcon;
    String subtitle;
    DateTime dateTime;
    Widget? amountExplainerWidget;
    String status;
    Category category;
    String? accountOwner;
    String? iban;
    String? note;
    List<Widget>? actions;

    if (argument is Transaction) {
      amountValue = argument.amount!;
      mainIcon = Icons.shopping_bag_outlined;
      subtitle = argument.bookingType == 'SEPA_CREDIT_TRANSFER_RETURN'
          ? 'From ${argument.senderName}'
          : 'To ${argument.recipientName!}';
      dateTime = argument.recordedAt!;

      status = 'Completed';
      category = argument.category!;
      accountOwner = user.person.firstName;
      iban = argument.recipientIban;
      note = argument.description;

      actions = [
        if (argument.bookingType == 'SEPA_CREDIT_TRANSFER') ...[
          IvoryListTile(
            title: 'Exclude from analytics',
            subtitle: 'Remove this transaction from analytics',
            startIcon: Icons.remove_circle_outline_rounded,
            trailingWidget: CupertinoSwitch(
              value: false,
              onChanged: (value) {},
            ),
            onTap: () {},
          ),
          IvoryListTile(
            title: 'Download statement',
            subtitle: "Locally in PDF format",
            startIcon: Icons.download_outlined,
            hasTrailing: false,
            onTap: () {},
          ),
          IvoryListTile(
            title: 'Convert into installments',
            startIcon: Icons.call_split_rounded,
            onTap: () => Navigator.pushNamed(
              context,
              SplitpayScreen.routeName,
              arguments: SplitpayScreenParams(transaction: argument),
            ),
          )
        ],
        if (argument.bookingType == 'AUTOMATIC_REPAYMENT')
          IvoryListTile(
            title: 'View bill',
            subtitle: "View this repayment bill",
            startIcon: Icons.receipt_outlined,
            onTap: () {},
          ),
        if (argument.bookingType != 'AUTOMATIC_REPAYMENT')
          IvoryListTile(
            title: 'Report this transaction',
            subtitle: "If you did't make this transaction",
            startIcon: Icons.warning_amber_rounded,
            hasTrailing: false,
            onTap: () {},
          )
      ];
    } else if (argument is UpcomingTransaction) {
      amountValue = argument.outstandingAmount!;
      mainIcon = Icons.currency_exchange;
      subtitle = 'From Reference account';
      dateTime = argument.dueDate!;
      amountExplainerWidget = RichText(
        text: TextSpan(
          text: '* ',
          children: [
            TextSpan(
              text: 'This is an automatic repayment and does not include the 5% interest rate. ',
              style: ClientConfig.getTextStyleScheme().bodySmallRegular.copyWith(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: 'Go to “Repayments” ',
              style: ClientConfig.getTextStyleScheme()
                  .bodySmallRegular
                  .copyWith(fontWeight: FontWeight.bold, color: ClientConfig.getColorScheme().secondary),
              recognizer: TapGestureRecognizer()
                ..onTap = () => Navigator.of(context).pushNamed(RepaymentsScreen.routeName),
            ),
            TextSpan(
              text: 'to view the repayment to be debited from your reference account.',
              style: ClientConfig.getTextStyleScheme().bodySmallRegular,
            ),
          ],
          style: ClientConfig.getTextStyleScheme()
              .bodySmallRegular
              .copyWith(color: ClientConfig.getColorScheme().secondary),
        ),
      );

      status = 'Upcoming';
      category = const Category(id: 'automaticRepayment', name: 'Automatic repayment');
      accountOwner = user.person.firstName;
      iban = user.personAccount.iban;

      actions = [
        IvoryListTile(
          title: 'Manage repayment settings',
          subtitle: "Go to 'Repayments'",
          startIcon: Icons.settings_outlined,
          onTap: () => Navigator.of(context).pushNamed(RepaymentsScreen.routeName),
        ),
      ];
    } else {
      throw Exception("Unknown argument type");
    }

    return ScreenScaffold(
      body: SingleChildScrollView(
        padding:
            EdgeInsets.symmetric(horizontal: ClientConfig.getCustomClientUiSettings().defaultScreenHorizontalPadding),
        child: _Content(
          amountValue: amountValue,
          mainIcon: mainIcon,
          subtitle: subtitle,
          dateTime: dateTime,
          amountExplainerWidget: amountExplainerWidget,
          status: status,
          category: category,
          accountOwner: accountOwner,
          iban: iban,
          note: note,
          actions: actions,
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final AmountValue amountValue;
  final IconData mainIcon;
  final String subtitle;
  final DateTime dateTime;
  final Widget? amountExplainerWidget;

  final String status;
  final Category category;
  final String? accountOwner;
  final String? iban;
  final String? note;

  final List<Widget>? actions;

  const _Content({
    required this.amountValue,
    required this.mainIcon,
    required this.subtitle,
    required this.dateTime,
    this.amountExplainerWidget,
    required this.status,
    required this.category,
    this.accountOwner,
    this.iban,
    this.note,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppToolbar(),
        const SizedBox(height: 16),
        Material(
          color: const Color(0xFFF8F9FA),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: SpacedColumn(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  space: 4,
                  children: [
                    Row(
                      children: [
                        Text(Format.euro(amountValue.value), style: ClientConfig.getTextStyleScheme().heading1),
                        if (amountExplainerWidget != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 2),
                            child: Text('*',
                                style: TextStyle(color: ClientConfig.getColorScheme().secondary, fontSize: 34)),
                          ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Icon(mainIcon, size: 26),
                        ),
                      ],
                    ),
                    Text(subtitle,
                        style:
                            ClientConfig.getTextStyleScheme().bodySmallRegular.copyWith(fontWeight: FontWeight.bold)),
                    Text(
                      Format.date(dateTime, pattern: 'MMM dd, HH:mm'),
                      style: ClientConfig.getTextStyleScheme().bodySmallRegular,
                    ),
                  ],
                ),
              ),
              if (amountExplainerWidget != null) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: amountExplainerWidget!,
                )
              ]
            ],
          ),
        ),
        const SizedBox(height: 24),
        SpacedColumn(
          space: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Details', style: ClientConfig.getTextStyleScheme().heading4),
            ExpandedDetailsRow(title: 'Status', trailing: status),
            ExpandedDetailsRow(
              title: 'Category',
              trailing: null,
              trailingWidget: Row(
                children: [
                  Icon(category.icon, size: 16),
                  const SizedBox(width: 8),
                  Text(category.name, style: ClientConfig.getTextStyleScheme().bodyLargeRegularBold),
                ],
              ),
            ),
            if (accountOwner != null) ExpandedDetailsRow(title: 'Reference account owner', trailing: accountOwner),
            if (iban != null) ExpandedDetailsRow(title: 'IBAN', trailing: iban),
            if (note != null) ...[
              Text('Note', style: ClientConfig.getTextStyleScheme().bodyLargeRegular),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(note!),
              ),
            ],
          ],
        ),
        const SizedBox(height: 24),
        if (actions != null) ...[
          Text('Actions', style: ClientConfig.getTextStyleScheme().heading4),
          const SizedBox(height: 8),
          ...actions!,
        ],
      ],
    );
  }
}
