import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:bondgrid/enums/document_subtype.dart';
import 'package:bondgrid/enums/document_type.dart';
import 'package:bondgrid/enums/notifications.dart';
import 'package:bondgrid/models/cash_balance.dart';
import 'package:bondgrid/models/document_list.dart';
import 'package:bondgrid/models/holding.dart';
import 'package:bondgrid/models/holding_list.dart';
import 'package:bondgrid/models/in_app_notification_list.dart';
import 'package:bondgrid/models/notification_preferences_list.dart';
import 'package:bondgrid/models/notification_setting.dart';
import 'package:bondgrid/models/referral_info.dart';
import 'package:bondgrid/models/transaction_list.dart';
import 'package:http/http.dart' as http;

import 'package:bondgrid/constants/config.dart';
import 'package:bondgrid/constants/error_codes.dart';
import 'package:bondgrid/models/api_exception.dart';
import 'package:bondgrid/models/user_agreement_list.dart';
import 'package:bondgrid/models/user_info.dart';
import 'package:bondgrid/models/user_verification.dart';
import 'package:bondgrid/services/http_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class HomeRepo {
  BaseService baseService = BaseService();

  Future<UserInfo> updateName(
      String? firstName, String? middleName, String? lastName) async {
    final payload = {
      "firstName": firstName,
      "middleName": middleName,
      "lastName": lastName,
    };

    final response =
        await baseService.callPost(ConfigurationFile.updateName, payload);
    if (response.containsKey('data') && response['data'] != null) {
      return UserInfo.fromJson(response['data']);
    } else {
      throw ApiException(
          ErrorCodes.INVALID_RESPONSE, "Response doesn't contain data");
    }
  }

  Future<UserInfo> updateDOB(String? dateOfBirth) async {
    final payload = {
      if (dateOfBirth != null && dateOfBirth.isNotEmpty)
        "dateOfBirth": dateOfBirth,
    };

    final response =
        await baseService.callPost(ConfigurationFile.updateDOB, payload);
    if (response.containsKey('data') && response['data'] != null) {
      return UserInfo.fromJson(response['data']);
    } else {
      throw ApiException(
          ErrorCodes.INVALID_RESPONSE, "Response doesn't contain data");
    }
  }

  Future<UserInfo> updateTaxId(String? taxID) async {
    final payload = {if (taxID != null && taxID.isNotEmpty) "taxID": taxID};

    final response =
        await baseService.callPost(ConfigurationFile.updateTaxId, payload);
    if (response.containsKey('data') && response['data'] != null) {
      return UserInfo.fromJson(response['data']);
    } else {
      throw ApiException(
          ErrorCodes.INVALID_RESPONSE, "Response doesn't contain data");
    }
  }

  Future<UserInfo> updateAddress(
      String? countryCode,
      String? street,
      String? additional,
      String? city,
      String? region,
      String? postalCode,
      String? countryOfTaxResidence,
      String? stateOfTaxResidence) async {
    final payload = {
      if (countryCode != null && countryCode.isNotEmpty)
        "countryCode": countryCode,
      if (street != null && street.isNotEmpty) "street": street,
      if (additional != null) "additional": additional,
      if (city != null && city.isNotEmpty) "city": city,
      if (region != null && region.isNotEmpty) "region": region,
      if (postalCode != null && postalCode.isNotEmpty) "postalCode": postalCode,
      if (countryOfTaxResidence != null && countryOfTaxResidence.isNotEmpty)
        "countryOfTaxResidence": countryOfTaxResidence,
      if (stateOfTaxResidence != null)
        "stateOfTaxResidence": stateOfTaxResidence,
    };
    final response =
        await baseService.callPost(ConfigurationFile.updateAddress, payload);
    if (response.containsKey('data') && response['data'] != null) {
      return UserInfo.fromJson(response['data']);
    } else {
      throw ApiException(
          ErrorCodes.INVALID_RESPONSE, "Response doesn't contain data");
    }
  }

  Future<UserInfo> updatePersonalDetails(
      String? dateOfBirth,
      String? countryCode,
      String? street,
      String? additional,
      String? city,
      String? region,
      String? postalCode,
      List<String>? countryOfCitizenship,
      String? countryOfTaxResidence,
      String? stateOfTaxResidence,
      String? residenceStatus,
      String? taxID) async {
    final payload = {
      if (dateOfBirth != null && dateOfBirth.isNotEmpty)
        "dateOfBirth": dateOfBirth,
      if (countryCode != null && countryCode.isNotEmpty)
        "countryCode": countryCode,
      if (street != null && street.isNotEmpty) "street": street,
      if (additional != null) "additional": additional,
      if (city != null && city.isNotEmpty) "city": city,
      if (region != null && region.isNotEmpty) "region": region,
      if (postalCode != null && postalCode.isNotEmpty) "postalCode": postalCode,
      if (countryOfCitizenship != null && countryOfCitizenship.isNotEmpty)
        "countryOfCitizenship": countryOfCitizenship,
      if (countryOfTaxResidence != null && countryOfTaxResidence.isNotEmpty)
        "countryOfTaxResidence": countryOfTaxResidence,
      if (stateOfTaxResidence != null)
        "stateOfTaxResidence": stateOfTaxResidence,
      if (residenceStatus != null && residenceStatus.isNotEmpty)
        "residenceStatus": residenceStatus,
      if (taxID != null && taxID.isNotEmpty) "taxID": taxID
    };

    final response = await baseService.callPost(
        ConfigurationFile.updatePersonalDetails, payload);
    if (response.containsKey('data') && response['data'] != null) {
      return UserInfo.fromJson(response['data']);
    } else {
      throw ApiException(
          ErrorCodes.INVALID_RESPONSE, "Response doesn't contain data");
    }
  }

  Future<UserInfo> updateEmploymentInformation(
      String? employmentStatus,
      String? employerName,
      String? occupation,
      String? occupationIndustry,
      bool? isFinraAffiliated,
      bool? isControlPublicCompany,
      bool? isPoliticallyExposed,
      bool? isFamilyPoliticallyExposed,
      List<String>? affiliatedExchange,
      List<String>? controlCorporation) async {
    final payload = {
      if (employmentStatus != null && employmentStatus.isNotEmpty)
        "employmentStatus": employmentStatus,
      if (employerName != null) "employerName": employerName,
      if (occupation != null) "occupation": occupation,
      if (occupationIndustry != null) "occupationIndustry": occupationIndustry,
      if (isFinraAffiliated != null) "isFinraAffiliated": isFinraAffiliated,
      if (isControlPublicCompany != null)
        "isControlPublicCompany": isControlPublicCompany,
      if (isPoliticallyExposed != null)
        "isPoliticallyExposed": isPoliticallyExposed,
      if (isFamilyPoliticallyExposed != null)
        "isFamilyPoliticallyExposed": isFamilyPoliticallyExposed,
      if (affiliatedExchange != null && affiliatedExchange.isNotEmpty)
        "affiliatedExchange": affiliatedExchange,
      if (controlCorporation != null && controlCorporation.isNotEmpty)
        "controlCorporation": controlCorporation
    };

    final response = await baseService.callPost(
        ConfigurationFile.updateEmploymentInformation, payload);
    if (response.containsKey('data') && response['data'] != null) {
      return UserInfo.fromJson(response['data']);
    } else {
      throw ApiException(
          ErrorCodes.INVALID_RESPONSE, "Response doesn't contain data");
    }
  }

  Future<UserInfo> updateFinancialProfile(
      String? investmentPriority,
      String? investmentHorizon,
      String? downturnReaction,
      String? annualIncome,
      String? netWorth) async {
    final payload = {
      if (investmentPriority != null && investmentPriority.isNotEmpty)
        "investmentPriority": investmentPriority,
      if (investmentHorizon != null && investmentHorizon.isNotEmpty)
        "investmentHorizon": investmentHorizon,
      if (downturnReaction != null && downturnReaction.isNotEmpty)
        "downturnReaction": downturnReaction,
      if (annualIncome != null && annualIncome.isNotEmpty)
        "annualIncome": annualIncome,
      if (netWorth != null && netWorth.isNotEmpty) "netWorth": netWorth
    };

    final response = await baseService.callPost(
        ConfigurationFile.updateFinancialProfile, payload);
    if (response.containsKey('data') && response['data'] != null) {
      return UserInfo.fromJson(response['data']);
    } else {
      throw ApiException(
          ErrorCodes.INVALID_RESPONSE, "Response doesn't contain data");
    }
  }

  Future<UserInfo> getUserInformation() async {
    final response =
        await baseService.callGet(ConfigurationFile.getUserInformation);
    if (response.containsKey('data') && response['data'] != null) {
      return UserInfo.fromJson(response['data']);
    } else {
      throw ApiException(
          ErrorCodes.INVALID_RESPONSE, "Response doesn't contain data");
    }
  }

  Future<UserVerification> getUserStatus() async {
    final response = await baseService.callGet(ConfigurationFile.getUserStatus);
    if (response.containsKey('data') && response['data'] != null) {
      return UserVerification.fromJson(response['data']);
    } else {
      throw ApiException(
          ErrorCodes.INVALID_RESPONSE, "Response doesn't contain data");
    }
  }

  Future<UserAgreementList> getUserAgreements() async {
    dynamic response =
        await baseService.callGet(ConfigurationFile.getUserAgreements);
    if (response.containsKey('data') && response['data'] != null) {
      return UserAgreementList.fromJson(response['data']);
    } else {
      throw ApiException(
          ErrorCodes.INVALID_RESPONSE, "Response doesn't contain data");
    }
  }

  Future<Holding> getHoldingById(String id) async {
    dynamic response =
        await baseService.callGet("${ConfigurationFile.getHoldingById}/$id");
    if (response.containsKey('data') &&
        response['data'] != null &&
        response['data'].containsKey('elements')) {
      return Holding.fromJson(response['data']['elements']);
    } else {
      throw ApiException(
          ErrorCodes.INVALID_RESPONSE, "Response doesn't contain data");
    }
  }

  Future<HoldingList> getHoldings() async {
    dynamic response =
        await baseService.callGet(ConfigurationFile.listHoldings);
    if (response.containsKey('data') && response['data'] != null) {
      return HoldingList.fromJson(response['data']);
    } else {
      throw ApiException(
          ErrorCodes.INVALID_RESPONSE, "Response doesn't contain data");
    }
  }

  Future<NotificationPreferencesList> getNotificationPreferences(
      NotificationType notificationType) async {
    dynamic response = await baseService.callGet(
      ConfigurationFile.getNotificationPreferences,
    );
    if (response.containsKey('data') && response['data'] != null) {
      return NotificationPreferencesList.fromJson(
          response['data'][notificationType.value]);
    } else {
      throw ApiException(
          ErrorCodes.INVALID_RESPONSE, "Response doesn't contain data");
    }
  }

  Future<NotificationSetting> updateNotificationPreferences(
      String notificationId, bool enabled) async {
    Map<String, dynamic> payload = {
      "notificationId": notificationId,
      "enabled": enabled,
    };

    final response = await baseService.callPost(
        ConfigurationFile.updateNotificationPreferences, payload);

    if (response.containsKey('data') && response['data'] != null) {
      return NotificationSetting.fromJson(response['data']);
    } else {
      throw ApiException(
          ErrorCodes.INVALID_RESPONSE, "Response doesn't contain data");
    }
  }

  Future<DocumentList> listDocuments(
      DocumentType documentType, DocumentSubType documentSubType) async {
    String documentTypeString = documentType.value;
    String documentSubTypeString = documentSubType.value;
    dynamic response = await baseService.callGet(
      ConfigurationFile.listDocuments,
      queryParams: {
        'documentType': documentTypeString,
        'documentSubType': documentSubTypeString
      },
    );
    if (response.containsKey('data') && response['data'] != null) {
      return DocumentList.fromJson(response['data']);
    } else {
      throw ApiException(
          ErrorCodes.INVALID_RESPONSE, "Response doesn't contain data");
    }
  }

  Future<File> getDocumentById(String id) async {
    final responseBytes = await baseService
        .callGetPdf("${ConfigurationFile.getDocumentById}/$id");

    if (responseBytes.isNotEmpty) {
      // save document to mobile device in order to render it
      // each time a document is viewed, this file is overwritten
      const filename = "current_document.pdf";
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$filename');

      // Delete the file if it exists
      if (await file.exists()) {
        await file.delete();
      }
      await file.writeAsBytes(responseBytes, flush: true);
      return file;
    } else {
      throw ApiException(
          ErrorCodes.INVALID_RESPONSE, "Response doesn't contain data");
    }
  }

  Future<TransactionList> getTransactionList() async {
    dynamic response =
        await baseService.callGet(ConfigurationFile.getTransactionActivity);
    if (response.containsKey('data') && response['data'] != null) {
      return TransactionList.fromJson(response['data']);
    } else {
      throw ApiException(
          ErrorCodes.INVALID_RESPONSE, "Response doesn't contain data");
    }
  }

  Future<TransactionList> listPendingTrades() async {
    dynamic response =
        await baseService.callGet(ConfigurationFile.listPendingTrades);
    if (response.containsKey('data') && response['data'] != null) {
      return TransactionList.fromJson(response['data']);
    } else {
      throw ApiException(
          ErrorCodes.INVALID_RESPONSE, "Response doesn't contain data");
    }
  }

  Future<CashBalance> getPortfolioValue() async {
    dynamic response =
        await baseService.callGet(ConfigurationFile.getPortfolioValue);
    if (response.containsKey('data') && response['data'] != null) {
      return CashBalance.fromJson(response['data']);
    } else {
      throw ApiException(
          ErrorCodes.INVALID_RESPONSE, "Response doesn't contain data");
    }
  }

  Future<Holding> createSellTrade(
      String amount, String cusip, String duration) async {
    Map<String, dynamic> payload = {
      "amount": amount,
      "cusip": cusip,
      "duration": duration
    };
    final response =
        await baseService.callPost(ConfigurationFile.sellTreasuryBill, payload);
    if (response.containsKey('data') &&
        response['data'] != null &&
        response['data'].containsKey('elements')) {
      return Holding.fromJson(response['data']['elements']);
    } else {
      throw ApiException(
          ErrorCodes.INVALID_RESPONSE, "Response doesn't contain data");
    }
  }

  Future<Map<String, dynamic>> toggleAutoRoll(
      String id, bool autoRollEnabled) async {
    Map<String, dynamic> payload = {
      "holdingId": id,
      "autoRoll": autoRollEnabled,
    };
    final response = await baseService.callPost(
        ConfigurationFile.toggleHoldingAutoRoll, payload);
    return response;
  }

  Future<UserVerification> submit(
      UserAgreementList? userAgreements,
      String? viewedTimestamp,
      String? signedTimestamp,
      String? endUserIp) async {
    // Extract the list of agreement Ids which has been shown to the user
    List<String> agreementIds = [];
    if (userAgreements != null && userAgreements.agreements.isNotEmpty) {
      agreementIds = userAgreements.agreements
          .map((agreement) => agreement.agreementId)
          .where((id) => id != null)
          .toList()
          .cast<String>();
    }
    final payload = {
      if (agreementIds.isNotEmpty) "agreementIds": agreementIds,
      if (viewedTimestamp != null && viewedTimestamp.isNotEmpty)
        "viewedTimestamp": viewedTimestamp,
      if (signedTimestamp != null && signedTimestamp.isNotEmpty)
        "signedTimestamp": signedTimestamp,
      if (endUserIp != null && endUserIp.isNotEmpty) "endUserIp": endUserIp
    };

    final response =
        await baseService.callPost(ConfigurationFile.submit, payload);
    if (response.containsKey('data') && response['data'] != null) {
      return UserVerification.fromJson(response['data']);
    } else {
      throw ApiException(
          ErrorCodes.INVALID_RESPONSE, "Response doesn't contain data");
    }
  }

  Future<List<dynamic>> getSuggestion(String input) async {
    String sessionToken = Random().nextInt(1000000).toString();
    List<dynamic> placeList;
    try {
      Map<String, String> requestHeaders = {
        HttpHeaders.contentTypeHeader: "*",
        HttpHeaders.accessControlAllowOriginHeader: "*",
        HttpHeaders.accessControlAllowMethodsHeader: "*",
        HttpHeaders.accessControlAllowHeadersHeader: "*"
      };
      String baseURL = ConfigurationFile.googleAutocompleteUrl;
      String kPLACESAPIKEY = ConfigurationFile.googleAutocompleteApiKey;
      String request =
          '$baseURL?input=$input&key=$kPLACESAPIKEY&sessiontoken=$sessionToken';
      var response =
          await http.get(Uri.parse(request), headers: requestHeaders);

      if (response.statusCode == 200) {
        placeList = json.decode(response.body)['predictions'];
      } else {
        throw Exception('Failed to load predictions');
      }
    } catch (e) {
      throw Error();
    }
    return placeList;
  }

  static Future<List<dynamic>> getPlaces(String placeId) async {
    String sessionToken = Random().nextInt(1000000).toString();
    List<dynamic> addressComponents;
    try {
      Map<String, String> requestHeaders = {
        HttpHeaders.contentTypeHeader: "*",
        HttpHeaders.accessControlAllowOriginHeader: "*",
        HttpHeaders.accessControlAllowMethodsHeader: "*",
        HttpHeaders.accessControlAllowHeadersHeader: "*"
      };
      String baseURL = ConfigurationFile.googlePlacesUrl;
      String kPLACESAPIKEY = ConfigurationFile.googleAutocompleteApiKey;
      String request =
          '$baseURL?place_id=$placeId&key=$kPLACESAPIKEY&sessiontoken=$sessionToken';
      var response =
          await http.get(Uri.parse(request), headers: requestHeaders);

      if (response.statusCode == 200) {
        addressComponents =
            json.decode(response.body)['result']['address_components'];
      } else {
        throw Exception('Failed to load predictions');
      }
    } catch (e) {
      throw Error();
    }
    return addressComponents;
  }

  Future<Map<String, dynamic>> changePassword(
      String oldPassword, String newPassword) async {
    final response = await baseService.callPost(
        ConfigurationFile.changePassword,
        {"old_password": oldPassword, "new_password": newPassword});
    return response;
  }

  Future<Map<String, dynamic>> requestAccountClosure() async {
    final response =
        await baseService.callPost(ConfigurationFile.requestAccountClosure, {});
    return response;
  }

  Future<Map<String, dynamic>> submitVerificationInfo(String userInput) async {
    final response = await baseService.callPost(
        ConfigurationFile.submitVerificationInfo, {"userInput": userInput});
    return response;
  }

  Future<Map<String, dynamic>> sendSupportRequest(String supportQuery) async {
    final response = await baseService.callPost(
        ConfigurationFile.sendSupportRequest, {"supportQuery": supportQuery});
    return response;
  }

  Future<Map<String, dynamic>> sendMissingReferralRequest(
      String missingReferralEmail) async {
    final response = await baseService.callPost(
        ConfigurationFile.sendMissingReferralRequest,
        {"missingReferralEmail": missingReferralEmail});
    return response;
  }

  Future<String> getDisplayedInterestRate() async {
    final response =
        await baseService.callGet(ConfigurationFile.displayedInterestRate);
    if (response.containsKey('data') && response['data'] != null) {
      return response['data'].toString();
    } else {
      throw ApiException(
          ErrorCodes.INVALID_RESPONSE, "Response doesn't contain data");
    }
  }

  Future<bool> checkInterstSummaryActive() async {
    final response = await baseService
        .callGet(ConfigurationFile.checkIfInterestSummaryActive);
    if (response.containsKey('data') && response['data'] != null) {
      return response['data'];
    } else {
      throw ApiException(
          ErrorCodes.INVALID_RESPONSE, "Response doesn't contain data");
    }
  }

  Future<bool> checkReferralProgramActive() async {
    final response = await baseService
        .callGet(ConfigurationFile.checkIfReferralProgramActive);
    if (response.containsKey('data') && response['data'] != null) {
      return response['data'];
    } else {
      throw ApiException(
          ErrorCodes.INVALID_RESPONSE, "Response doesn't contain data");
    }
  }

  Future<String> getReferralBonusValue() async {
    final response =
        await baseService.callGet(ConfigurationFile.getReferralBonusValue);
    if (response.containsKey('data') && response['data'] != null) {
      return response['data'].toString();
    } else {
      throw ApiException(
          ErrorCodes.INVALID_RESPONSE, "Response doesn't contain data");
    }
  }

  Future<ReferralInfo> getReferralInfo() async {
    dynamic response =
        await baseService.callGet(ConfigurationFile.getReferralInfo);
    if (response.containsKey('data') && response['data'] != null) {
      return ReferralInfo.fromJson(response['data']);
    } else {
      throw ApiException(
          ErrorCodes.INVALID_RESPONSE, "Response doesn't contain data");
    }
  }

  Future<InAppNotificationList> getInAppNotificationList() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    Map<String, String> queryParams = {
      'platform': Platform.operatingSystem,
      'appVersion': packageInfo.version,
    };
    dynamic response = await baseService.callPost(
        ConfigurationFile.getInAppNotifications, queryParams);
    if (response.containsKey('data') && response['data'] != null) {
      return InAppNotificationList.fromJson(response['data']);
    } else {
      throw ApiException(
          ErrorCodes.INVALID_RESPONSE, "Response doesn't contain data");
    }
  }

  Future<Map<String, dynamic>> markNotificationAsProcessed(String id) async {
    final response = await baseService.callPost(
        "${ConfigurationFile.markInAppNotificationAsProcessed}/$id", {});
    return response;
  }
}
