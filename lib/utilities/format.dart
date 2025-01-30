import 'dart:math';
import 'package:bondgrid/enums/transaction_direction.dart';
import 'package:intl/intl.dart';
import 'package:plaid_flutter/plaid_flutter.dart';

String changeDateFormat(String inputDate) {
  DateTime parsedDate = DateTime.parse(inputDate);
  String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
  return formattedDate;
}

String formatDate(String? dateStr) {
  if (dateStr == null) return '';
  DateTime dateTime = DateTime.parse(dateStr).toLocal();
  return DateFormat('MMM d, y').format(dateTime);
}

String formatDateWithTime(String? dateStr) {
  if (dateStr == null) return '';
  DateTime dateTime = DateTime.parse(dateStr).toLocal();

  String formattedDate = DateFormat('MMM d, y').format(dateTime);
  String formattedTime = DateFormat('hh:mm a').format(dateTime);

  return "$formattedDate at $formattedTime";
}

String formatNumberShares(double? value) {
  if (value == null) return "0";
  if (value % 1 == 0) {
    // No decimal part
    return value.toStringAsFixed(0);
  } else {
    // Restrict to two decimal places
    return value.toStringAsFixed(2);
  }
}

String cleanUpString(String input) {
  return input.split('_').join(' ');
}

bool isZero(String amountString) {
  final amount = double.tryParse(amountString);
  if (amount == null) return true;
  return amount == 0.0;
}

bool isPositive(String amountString) {
  final amount = double.tryParse(amountString);
  if (amount == null) return false;
  return amount > 0.0;
}

String formatYield(String? yield) {
  if (yield == null) return "0.00";

  double amount = double.tryParse(yield) ?? 0.0;
  double roundedAmount = (amount * 100).floor() / 100;
  String formattedYield = roundedAmount.toStringAsFixed(2);
  return formattedYield;
}

String formatAmount(String amountString,
    {bool keepZero = true,
    TransactionDirection? direction,
    bool showPositiveSign = false}) {
  double amount = double.tryParse(amountString) ?? 0.0;
  String sign = '';
  if (direction != null) {
    if (direction == TransactionDirection.CREDIT && amount != 0) {
      sign = "+";
    } else if (direction == TransactionDirection.DEBIT && amount != 0) {
      sign = "-";
    }
  } else if (amount < 0) {
    // need to set the sign if no direction is specified
    sign = "-";
  } else if (amount > 0 && showPositiveSign) {
    sign = "+";
  }

  // Truncate to two decimal places. To avoid any precision issues, we use string
  // based conversion instead of truncateToDecimalPlaces function
  String truncatedAmountString = amount.abs().toStringAsFixed(2);
  double truncatedAmount = double.parse(truncatedAmountString);

  if (keepZero) {
    return "$sign\$${NumberFormat('#,##0.00', 'en_US').format(truncatedAmount)}";
  } else {
    return "$sign\$${NumberFormat('#,##0.##', 'en_US').format(truncatedAmount)}";
  }
}

double truncateToDecimalPlaces(num value, int fractionalDigits) =>
    (value * pow(10, fractionalDigits)).truncate() / pow(10, fractionalDigits);

Map<String, dynamic> getPlaidLinkJson(LinkSuccess event) {
  final token = event.publicToken;
  final metadata = event.metadata;

  // Convert institution to a map if it's not null
  Map<String, dynamic>? institutionMap;
  if (metadata.institution != null) {
    institutionMap = {
      'id': metadata.institution!.id,
      'name': metadata.institution!.name,
    };
  }

  // Convert accounts to a list of maps
  List<Map<String, dynamic>> accountsList = metadata.accounts.map((account) {
    return {
      'id': account.id,
      'mask': account.mask,
      'name': account.name,
      'type': account.type,
      'subtype': account.subtype,
      'verificationStatus': account.verificationStatus,
    };
  }).toList();

  Map<String, dynamic> jsonMap = {
    'publicToken': token,
    'metadata': {
      'linkSessionId': metadata.linkSessionId,
      'institution': institutionMap,
      'accounts': accountsList,
    }
  };

  return jsonMap;
}
