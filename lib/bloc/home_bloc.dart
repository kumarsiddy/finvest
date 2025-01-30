import 'dart:io';

import 'package:bondgrid/constants/error_codes.dart';
import 'package:bondgrid/constants/error_message.dart';
import 'package:bondgrid/enums/document_subtype.dart';
import 'package:bondgrid/enums/document_type.dart';
import 'package:bondgrid/enums/notifications.dart';
import 'package:bondgrid/enums/verification_status.dart';
import 'package:bondgrid/models/api_exception.dart';
import 'package:bondgrid/models/cash_balance.dart';
import 'package:bondgrid/models/document_list.dart';
import 'package:bondgrid/models/holding.dart';
import 'package:bondgrid/models/holding_list.dart';
import 'package:bondgrid/models/in_app_notification_list.dart';
import 'package:bondgrid/models/notification_preferences_list.dart';
import 'package:bondgrid/models/notification_setting.dart';
import 'package:bondgrid/models/referral_info.dart';
import 'package:bondgrid/models/transaction_list.dart';
import 'package:bondgrid/models/user_agreement_list.dart';
import 'package:bondgrid/models/user_info.dart';
import 'package:bondgrid/models/user_verification.dart';
import 'package:bondgrid/repo/home_repo.dart';
import 'package:bondgrid/services/cache_data.dart';
import 'package:bondgrid/services/token_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum HomeStateStatus {
  initial,
  loading,
  success,
  failure,
}

class HomeState extends Equatable {
  final HomeStateStatus status;
  final String errorMessage;

  const HomeState(
      {this.status = HomeStateStatus.initial, this.errorMessage = ""});

  @override
  List<Object?> get props => [status, errorMessage];
}

class FailureState extends HomeState {
  const FailureState(String errorMessage)
      : super(status: HomeStateStatus.failure, errorMessage: errorMessage);

  @override
  List<Object?> get props => [status, errorMessage];
}

class GetUserInfoSuccessState extends HomeState {
  UserInfo userInfo;

  GetUserInfoSuccessState({required this.userInfo})
      : super(status: HomeStateStatus.success);

  @override
  List<Object> get props => [userInfo];
}

class GetUserStatusSuccessState extends HomeState {
  final UserVerification verification;

  const GetUserStatusSuccessState({required this.verification})
      : super(status: HomeStateStatus.success);

  @override
  List<Object> get props => [verification];
}

class GetUserAgreementsSuccessState extends HomeState {
  final UserAgreementList userAgreements;

  const GetUserAgreementsSuccessState({required this.userAgreements})
      : super(status: HomeStateStatus.success);

  @override
  List<Object> get props => [userAgreements];
}

class GetTransactionListSuccessState extends HomeState {
  final TransactionList transactionList;

  const GetTransactionListSuccessState({required this.transactionList})
      : super(status: HomeStateStatus.success);

  @override
  List<Object> get props => [transactionList];
}

class ListPendingTradesSuccessState extends HomeState {
  final TransactionList tradeList;

  const ListPendingTradesSuccessState({required this.tradeList})
      : super(status: HomeStateStatus.success);

  @override
  List<Object> get props => [tradeList];
}

class GetNotificationPreferencesListSuccessState extends HomeState {
  final NotificationPreferencesList notificationPreferencesList;

  const GetNotificationPreferencesListSuccessState(
      {required this.notificationPreferencesList})
      : super(status: HomeStateStatus.success);

  @override
  List<Object> get props => [notificationPreferencesList];
}

class UpdateNotificationPreferencesSuccessState extends HomeState {
  final NotificationSetting notificationSetting;

  const UpdateNotificationPreferencesSuccessState(
      {required this.notificationSetting})
      : super(status: HomeStateStatus.success);

  @override
  List<Object> get props => [notificationSetting];
}

class GetDocumentListSuccessState extends HomeState {
  final DocumentList documentList;

  const GetDocumentListSuccessState({required this.documentList})
      : super(status: HomeStateStatus.success);

  @override
  List<Object> get props => [documentList];
}

class GetDocumentByIdSuccessState extends HomeState {
  final File documentPdf;
  const GetDocumentByIdSuccessState({required this.documentPdf})
      : super(status: HomeStateStatus.success);

  @override
  List<Object> get props => [documentPdf];
}

class GetHoldingListSuccessState extends HomeState {
  final HoldingList holdingList;

  const GetHoldingListSuccessState({required this.holdingList})
      : super(status: HomeStateStatus.success);

  @override
  List<Object> get props => [holdingList];
}

class GetHoldingByIdLoadingState extends HomeState {
  const GetHoldingByIdLoadingState() : super(status: HomeStateStatus.loading);

  @override
  List<Object> get props => [];
}

class GetHoldingByIdSuccessState extends HomeState {
  final Holding holding;

  const GetHoldingByIdSuccessState({required this.holding})
      : super(status: HomeStateStatus.success);

  @override
  List<Object> get props => [holding];
}

class GetPortfolioValueSuccessState extends HomeState {
  final CashBalance portfolioValue;

  const GetPortfolioValueSuccessState({required this.portfolioValue})
      : super(status: HomeStateStatus.success);

  @override
  List<Object> get props => [portfolioValue];
}

class GetInterestSummaryStatusSuccessState extends HomeState {
  final bool interestSummaryActive;

  const GetInterestSummaryStatusSuccessState(
      {required this.interestSummaryActive})
      : super(status: HomeStateStatus.success);

  @override
  List<Object> get props => [interestSummaryActive];
}

class SubmitUserVerificationLoadingState extends HomeState {
  const SubmitUserVerificationLoadingState()
      : super(status: HomeStateStatus.loading);

  @override
  List<Object> get props => [];
}

class SubmitUserVerificationSuccessState extends HomeState {
  final UserVerification verification;

  const SubmitUserVerificationSuccessState({required this.verification})
      : super(status: HomeStateStatus.success);

  @override
  List<Object> get props => [verification];
}

class UpdatePersonalDetailsLoadingState extends HomeState {
  const UpdatePersonalDetailsLoadingState()
      : super(status: HomeStateStatus.loading);

  @override
  List<Object> get props => [];
}

class UpdatePersonalDetailsSuccessState extends HomeState {
  final UserInfo userInfo;

  const UpdatePersonalDetailsSuccessState({required this.userInfo})
      : super(status: HomeStateStatus.success);

  @override
  List<Object> get props => [userInfo];
}

class UpdateNameLoadingState extends HomeState {
  const UpdateNameLoadingState() : super(status: HomeStateStatus.loading);

  @override
  List<Object> get props => [];
}

class UpdateNameSuccessState extends HomeState {
  final UserInfo userInfo;

  const UpdateNameSuccessState({required this.userInfo})
      : super(status: HomeStateStatus.success);

  @override
  List<Object> get props => [userInfo];
}

class UpdateDOBLoadingState extends HomeState {
  const UpdateDOBLoadingState() : super(status: HomeStateStatus.loading);

  @override
  List<Object> get props => [];
}

class UpdateDOBSuccessState extends HomeState {
  final UserInfo userInfo;

  const UpdateDOBSuccessState({required this.userInfo})
      : super(status: HomeStateStatus.success);

  @override
  List<Object> get props => [userInfo];
}

class UpdateTaxIdLoadingState extends HomeState {
  const UpdateTaxIdLoadingState() : super(status: HomeStateStatus.loading);

  @override
  List<Object> get props => [];
}

class UpdateTaxIdSuccessState extends HomeState {
  final UserInfo userInfo;

  const UpdateTaxIdSuccessState({required this.userInfo})
      : super(status: HomeStateStatus.success);

  @override
  List<Object> get props => [userInfo];
}

class UpdateAddressLoadingState extends HomeState {
  const UpdateAddressLoadingState() : super(status: HomeStateStatus.loading);

  @override
  List<Object> get props => [];
}

class UpdateAddressSuccessState extends HomeState {
  final UserInfo userInfo;

  const UpdateAddressSuccessState({required this.userInfo})
      : super(status: HomeStateStatus.success);

  @override
  List<Object> get props => [userInfo];
}

class UpdateEmploymentInfoLoadingState extends HomeState {
  const UpdateEmploymentInfoLoadingState()
      : super(status: HomeStateStatus.loading);

  @override
  List<Object> get props => [];
}

class UpdateEmploymentInfoSuccessState extends HomeState {
  final UserInfo userInfo;

  const UpdateEmploymentInfoSuccessState({required this.userInfo})
      : super(status: HomeStateStatus.success);

  @override
  List<Object> get props => [userInfo];
}

class UpdateFinancialProfileLoadingState extends HomeState {
  const UpdateFinancialProfileLoadingState()
      : super(status: HomeStateStatus.loading);

  @override
  List<Object> get props => [];
}

class UpdateFinancialProfileSuccessState extends HomeState {
  final UserInfo userInfo;

  const UpdateFinancialProfileSuccessState({required this.userInfo})
      : super(status: HomeStateStatus.success);

  @override
  List<Object> get props => [userInfo];
}

class SearchAddressSuccessState extends HomeState {
  final List<dynamic> suggestions;

  const SearchAddressSuccessState({required this.suggestions})
      : super(status: HomeStateStatus.success);

  @override
  List<Object> get props => [suggestions];
}

class CreateSellLoadingState extends HomeState {
  const CreateSellLoadingState() : super(status: HomeStateStatus.loading);

  @override
  List<Object?> get props => [status];
}

class CreateSellSuccessState extends HomeState {
  final String amount;
  final Holding holding;

  const CreateSellSuccessState({required this.amount, required this.holding})
      : super(status: HomeStateStatus.success);

  @override
  List<Object?> get props => [status, amount, holding];
}

class ToggleAutoRollSuccessState extends HomeState {
  final bool autoRollEnabled;

  const ToggleAutoRollSuccessState({required this.autoRollEnabled})
      : super(status: HomeStateStatus.success);

  @override
  List<Object?> get props => [status, autoRollEnabled];
}

class ChangePasswordLoadingState extends HomeState {
  const ChangePasswordLoadingState() : super(status: HomeStateStatus.loading);

  @override
  List<Object> get props => [];
}

class ChangePasswordSuccessState extends HomeState {
  const ChangePasswordSuccessState() : super(status: HomeStateStatus.success);

  @override
  List<Object> get props => [];
}

class RequestAccountClosureLoadingState extends HomeState {
  const RequestAccountClosureLoadingState()
      : super(status: HomeStateStatus.loading);

  @override
  List<Object> get props => [];
}

class RequestAccountClosureSuccessState extends HomeState {
  const RequestAccountClosureSuccessState()
      : super(status: HomeStateStatus.success);

  @override
  List<Object> get props => [];
}

class SubmitVerificationInfoLoadingState extends HomeState {
  const SubmitVerificationInfoLoadingState()
      : super(status: HomeStateStatus.loading);

  @override
  List<Object> get props => [];
}

class SendSupportRequestLoadingState extends HomeState {
  const SendSupportRequestLoadingState()
      : super(status: HomeStateStatus.loading);

  @override
  List<Object> get props => [];
}

class SubmitVerificationInfoSuccessState extends HomeState {
  const SubmitVerificationInfoSuccessState()
      : super(status: HomeStateStatus.success);

  @override
  List<Object> get props => [];
}

class SendSupportRequestSuccessState extends HomeState {
  const SendSupportRequestSuccessState()
      : super(status: HomeStateStatus.success);

  @override
  List<Object> get props => [];
}

class MissingReferralRequestLoadingState extends HomeState {
  const MissingReferralRequestLoadingState()
      : super(status: HomeStateStatus.loading);

  @override
  List<Object> get props => [];
}

class MissingReferralRequestSuccessState extends HomeState {
  const MissingReferralRequestSuccessState()
      : super(status: HomeStateStatus.success);

  @override
  List<Object> get props => [];
}

class CheckReferralProgramStatusSuccessStatus extends HomeState {
  final bool active;

  const CheckReferralProgramStatusSuccessStatus({required this.active})
      : super(status: HomeStateStatus.success);

  @override
  List<Object> get props => [active];
}

class GetReferralBonusValueSuccessState extends HomeState {
  final String referralBonus;

  const GetReferralBonusValueSuccessState({required this.referralBonus})
      : super(status: HomeStateStatus.success);

  @override
  List<Object> get props => [referralBonus];
}

class GetPortfolioValueLoadingState extends HomeState {
  const GetPortfolioValueLoadingState()
      : super(status: HomeStateStatus.loading);
}

class GetUserInfoLoadingState extends HomeState {
  const GetUserInfoLoadingState() : super(status: HomeStateStatus.loading);
}

class GetTransactionListLoadingState extends HomeState {
  const GetTransactionListLoadingState()
      : super(status: HomeStateStatus.loading);
}

class GetHoldingListLoadingState extends HomeState {
  const GetHoldingListLoadingState() : super(status: HomeStateStatus.loading);
}

class LoadHomeScreenInitialLoadingState extends HomeState {
  const LoadHomeScreenInitialLoadingState()
      : super(status: HomeStateStatus.loading);
}

class LoadReferralScreenInitialLoadingState extends HomeState {
  const LoadReferralScreenInitialLoadingState()
      : super(status: HomeStateStatus.loading);
}

class LoadInAppNotificationSuccessState extends HomeState {
  final InAppNotificationList notificationList;

  const LoadInAppNotificationSuccessState({required this.notificationList})
      : super(status: HomeStateStatus.success);

  @override
  List<Object> get props => [notificationList];
}

class MarkNotificationAsProcessedSuccessState extends HomeState {
  const MarkNotificationAsProcessedSuccessState()
      : super(status: HomeStateStatus.success);

  @override
  List<Object> get props => [];
}

class LoadHomeScreenInitialSuccessState extends HomeState {
  final CashBalance portfolioValue;
  final UserInfo userInfo;
  final TransactionList transactionList;
  final HoldingList holdingList;
  final bool interestSummaryActive;

  const LoadHomeScreenInitialSuccessState(
      {required this.portfolioValue,
      required this.userInfo,
      required this.transactionList,
      required this.holdingList,
      required this.interestSummaryActive})
      : super(status: HomeStateStatus.success);

  @override
  List<Object> get props =>
      [portfolioValue, userInfo, transactionList, holdingList];
}

class LoadProfileScreenInitialLoadingState extends HomeState {
  const LoadProfileScreenInitialLoadingState()
      : super(status: HomeStateStatus.loading);

  @override
  List<Object> get props => [];
}

class LoadProfileScreenInitialSuccessState extends HomeState {
  final UserInfo userInfo;
  final bool active;

  const LoadProfileScreenInitialSuccessState(
      {required this.userInfo, required this.active})
      : super(status: HomeStateStatus.success);

  @override
  List<Object> get props => [userInfo, active];
}

class LoadReferralScreenInitialSuccessState extends HomeState {
  final ReferralInfo referralInfo;

  const LoadReferralScreenInitialSuccessState({required this.referralInfo})
      : super(status: HomeStateStatus.success);

  @override
  List<Object> get props => [referralInfo];
}

class HomeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetUserInfoEvent extends HomeEvent {
  final bool useCache;

  GetUserInfoEvent({this.useCache = true});
}

class GetUserStatusEvent extends HomeEvent {
  GetUserStatusEvent();
}

class GetUserAgreementsEvent extends HomeEvent {
  GetUserAgreementsEvent();
}

class GetTransactionListEvent extends HomeEvent {
  final bool useCache;

  GetTransactionListEvent({this.useCache = true});
}

class ListPendingTradesEvent extends HomeEvent {
  ListPendingTradesEvent();
}

class GetNotificationPreferencesEvent extends HomeEvent {
  final NotificationType notificationType;

  GetNotificationPreferencesEvent(this.notificationType);
}

class UpdateNotificationPreferencesEvent extends HomeEvent {
  final String notificationId;
  final bool enabled;

  UpdateNotificationPreferencesEvent(
    this.notificationId,
    this.enabled,
  );
}

class GetDocumentListEvent extends HomeEvent {
  final DocumentType documentType;
  final DocumentSubType documentSubType;

  GetDocumentListEvent(this.documentType, this.documentSubType);
}

class GetDocumentByIdEvent extends HomeEvent {
  final String id;

  GetDocumentByIdEvent(this.id);
}

class GetHoldingListEvent extends HomeEvent {
  final bool useCache;

  GetHoldingListEvent({this.useCache = true});
}

class GetHoldingByIdEvent extends HomeEvent {
  final String id;
  final bool useCache;

  GetHoldingByIdEvent(this.id, {this.useCache = true});
}

class GetPortfolioValueEvent extends HomeEvent {
  final bool useCache;

  GetPortfolioValueEvent({this.useCache = true});
}

class GetInterestSummaryStatusEvent extends HomeEvent {
  GetInterestSummaryStatusEvent();
}

class SubmitUserVerificationEvent extends HomeEvent {
  final UserAgreementList? userAgreements;
  final String? viewedTimestamp;
  final String? signedTimestamp;
  final String? endUserIp;

  SubmitUserVerificationEvent(
      {this.userAgreements,
      this.viewedTimestamp,
      this.signedTimestamp,
      this.endUserIp});
}

class UpdateNameEvent extends HomeEvent {
  final String? firstName;
  final String? middleName;
  final String? lastName;

  UpdateNameEvent(this.firstName, this.middleName, this.lastName);
}

class UpdateDOBEvent extends HomeEvent {
  final String? dateOfBirth;

  UpdateDOBEvent(this.dateOfBirth);
}

class UpdateTaxIDEvent extends HomeEvent {
  final String? taxID;

  UpdateTaxIDEvent(this.taxID);
}

class UpdateAddressEvent extends HomeEvent {
  final String? countryCode;
  final String? street;
  final String? additional;
  final String? city;
  final String? region;
  final String? postalCode;
  final String? countryOfTaxResidence;
  final String? stateOfTaxResidence;

  UpdateAddressEvent(
      this.countryCode,
      this.street,
      this.additional,
      this.city,
      this.region,
      this.postalCode,
      this.countryOfTaxResidence,
      this.stateOfTaxResidence);
}

class UpdatePersonalDetailsEvent extends HomeEvent {
  final String? dateOfBirth;
  final String? countryCode;
  final String? street;
  final String? additional;
  final String? city;
  final String? region;
  final String? postalCode;
  final List<String>? countryOfCitizenship;
  final String? countryOfTaxResidence;
  final String? stateOfTaxResidence;
  final String? residenceStatus;
  final String? taxID;

  UpdatePersonalDetailsEvent(
      this.dateOfBirth,
      this.countryCode,
      this.street,
      this.additional,
      this.city,
      this.region,
      this.postalCode,
      this.countryOfCitizenship,
      this.countryOfTaxResidence,
      this.stateOfTaxResidence,
      this.residenceStatus,
      this.taxID);
}

class UpdateEmploymentInfoEvent extends HomeEvent {
  final String? employmentStatus;
  final String? employerName;
  final String? occupation;
  final String? occupationIndustry;

  final bool? isFinraAffiliated;
  final bool? isControlPublicCompany;
  final bool? isPoliticallyExposed;
  final bool? isFamilyPoliticallyExposed;

  final List<String>? affiliatedExchange;
  final List<String>? controlCorporation;

  UpdateEmploymentInfoEvent(
      this.employmentStatus,
      this.employerName,
      this.occupation,
      this.occupationIndustry,
      this.isFinraAffiliated,
      this.isControlPublicCompany,
      this.isPoliticallyExposed,
      this.isFamilyPoliticallyExposed,
      this.affiliatedExchange,
      this.controlCorporation);
}

class UpdateFinancialProfileEvent extends HomeEvent {
  final String? investmentPriority;
  final String? investmentHorizon;
  final String? downturnReaction;
  final String? annualIncome;
  final String? netWorth;

  UpdateFinancialProfileEvent(this.investmentPriority, this.investmentHorizon,
      this.downturnReaction, this.annualIncome, this.netWorth);
}

class GetAddressSuggestionsEvent extends HomeEvent {
  final String input;

  GetAddressSuggestionsEvent(this.input);

  @override
  List<Object> get props => [input];
}

class CreateSellEvent extends HomeEvent {
  final String id;
  final String amount;
  final String cusip;
  final String duration;

  CreateSellEvent(this.id, this.amount, this.cusip, this.duration);
}

class ToggleAutoRollEvent extends HomeEvent {
  final String holdingId;
  final bool autoRollEnabled;

  ToggleAutoRollEvent(this.holdingId, this.autoRollEnabled);
}

class ChangePasswordEvent extends HomeEvent {
  final String oldPassword;
  final String newPassword;

  ChangePasswordEvent(this.oldPassword, this.newPassword);
}

class RequestAccountClosureEvent extends HomeEvent {
  RequestAccountClosureEvent();
}

class SubmitVerificationInfoEvent extends HomeEvent {
  final String userInput;

  SubmitVerificationInfoEvent(this.userInput);
}

class SendSupportRequestEvent extends HomeEvent {
  final String supportQuery;

  SendSupportRequestEvent(this.supportQuery);
}

class MissingReferralRequestEvent extends HomeEvent {
  final String missingReferralEmail;

  MissingReferralRequestEvent(this.missingReferralEmail);
}

class CheckReferralProgramStatusEvent extends HomeEvent {
  CheckReferralProgramStatusEvent();
}

class GetReferralBonusValueEvent extends HomeEvent {
  GetReferralBonusValueEvent();
}

class GetReferralCodeEvent extends HomeEvent {
  GetReferralCodeEvent();
}

class LoadHomeScreenInitialDataEvent extends HomeEvent {
  final bool useCache;

  LoadHomeScreenInitialDataEvent({this.useCache = true});
}

class LoadInAppNotifications extends HomeEvent {
  LoadInAppNotifications();
}

class MarkNotificationAsProcessed extends HomeEvent {
  final String id;

  MarkNotificationAsProcessed(this.id);
}

class LoadProfileScreenInitialDataEvent extends HomeEvent {
  final bool useCache;

  LoadProfileScreenInitialDataEvent({this.useCache = true});
}

class LoadReferralScreenInitialDataEvent extends HomeEvent {
  LoadReferralScreenInitialDataEvent();
}

extension on HomeBloc {
  void _handleError(dynamic error, Emitter<HomeState> emit) {
    if (error is ApiException) {
      switch (error.errorCode) {
        case ErrorCodes.INVALID_DATE_FORMAT:
          emit(const FailureState(
              "Invalid date of birth. Please fix it to continue."));
          break;
        case ErrorCodes.INVALID_PASSWORD:
          emit(const FailureState(
              "Your email or password wasn't recognized. Please try again."));
          break;
        default:
          emit(FailureState(ErrorMessage.unexpectedErrorMessage));
          break;
      }
    } else {
      emit(FailureState(ErrorMessage.unexpectedErrorMessage));
    }
  }
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepo homeRepo;

  HomeBloc(this.homeRepo) : super(const HomeState()) {
    on<GetUserInfoEvent>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = await TokenService.getJWTToken();
      // Try to load cached data
      if (currentUserId != null && event.useCache) {
        final cachedUserInfoData = readCachedData(
            prefs, 'cachedUserInfo', currentUserId,
            ageLimit: null);
        UserInfo? cachedUserInfo = cachedUserInfoData != null
            ? UserInfo.fromJson(cachedUserInfoData)
            : null;
        // We don't load the cached user info if the user status is processing
        // because it could have changed since the data was cached last
        if (cachedUserInfo != null &&
            cachedUserInfo.verification.status !=
                VerificationStatus.PROCESSING) {
          emit(GetUserInfoSuccessState(userInfo: cachedUserInfo));
        } else {
          emit(const GetUserInfoLoadingState());
        }
      } else {
        emit(const GetUserInfoLoadingState());
      }

      try {
        UserInfo response = await homeRepo.getUserInformation();
        if (currentUserId != null) {
          await cacheData(
              prefs, 'cachedUserInfo', response.toJson(), currentUserId);
        }
        emit(GetUserInfoSuccessState(userInfo: response));
      } catch (error) {
        _handleError(error, emit);
      }
    });

    on<GetUserStatusEvent>((event, emit) async {
      emit(const HomeState(status: HomeStateStatus.loading));
      try {
        UserVerification response = await homeRepo.getUserStatus();
        emit(GetUserStatusSuccessState(verification: response));
      } catch (error) {
        _handleError(error, emit);
      }
    });

    on<GetUserAgreementsEvent>((event, emit) async {
      emit(const HomeState(status: HomeStateStatus.loading));
      try {
        UserAgreementList response = await homeRepo.getUserAgreements();
        emit(GetUserAgreementsSuccessState(userAgreements: response));
      } catch (error) {
        _handleError(error, emit);
      }
    });

    on<GetTransactionListEvent>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = await TokenService.getJWTToken();
      // Try to load cached data
      if (currentUserId != null && event.useCache) {
        final cachedTransactionListData = readCachedData(
            prefs, 'cachedTransactionList', currentUserId,
            ageLimit: const Duration(hours: 12));
        TransactionList? cachedTransactionList =
            cachedTransactionListData != null
                ? TransactionList.fromJson(cachedTransactionListData)
                : null;
        if (cachedTransactionList == null) {
          emit(const GetTransactionListLoadingState());
        } else {
          emit(GetTransactionListSuccessState(
              transactionList: cachedTransactionList));
        }
      } else {
        emit(const GetTransactionListLoadingState());
      }

      try {
        TransactionList response = await homeRepo.getTransactionList();
        if (currentUserId != null) {
          await cacheData(
              prefs, 'cachedTransactionList', response.toJson(), currentUserId);
        }
        emit(GetTransactionListSuccessState(transactionList: response));
      } catch (error) {
        _handleError(error, emit);
      }
    });

    on<ListPendingTradesEvent>((event, emit) async {
      emit(const HomeState(status: HomeStateStatus.loading));
      try {
        TransactionList response = await homeRepo.listPendingTrades();
        emit(ListPendingTradesSuccessState(tradeList: response));
      } catch (error) {
        _handleError(error, emit);
      }
    });

    on<GetNotificationPreferencesEvent>((event, emit) async {
      emit(const HomeState(status: HomeStateStatus.loading));
      try {
        NotificationPreferencesList response =
            await homeRepo.getNotificationPreferences(event.notificationType);
        emit(GetNotificationPreferencesListSuccessState(
            notificationPreferencesList: response));
      } catch (error) {
        _handleError(error, emit);
      }
    });

    on<UpdateNotificationPreferencesEvent>((event, emit) async {
      emit(const HomeState(status: HomeStateStatus.loading));
      try {
        NotificationSetting response = await homeRepo
            .updateNotificationPreferences(event.notificationId, event.enabled);
        emit(UpdateNotificationPreferencesSuccessState(
            notificationSetting: response));
      } catch (error) {
        _handleError(error, emit);
      }
    });

    on<GetDocumentListEvent>((event, emit) async {
      emit(const HomeState(status: HomeStateStatus.loading));
      try {
        DocumentList response = await homeRepo.listDocuments(
            event.documentType, event.documentSubType);
        emit(GetDocumentListSuccessState(documentList: response));
      } catch (error) {
        _handleError(error, emit);
      }
    });

    on<GetDocumentByIdEvent>((event, emit) async {
      emit(const HomeState(status: HomeStateStatus.loading));
      try {
        File response = await homeRepo.getDocumentById(event.id);
        emit(GetDocumentByIdSuccessState(documentPdf: response));
      } catch (error) {
        _handleError(error, emit);
      }
    });

    on<GetHoldingListEvent>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = await TokenService.getJWTToken();

      // Try to load cached data
      if (currentUserId != null && event.useCache) {
        final cachedHoldingListData = readCachedData(
            prefs, 'cachedHoldingList', currentUserId,
            ageLimit: const Duration(hours: 12));
        HoldingList? cachedHoldingList = cachedHoldingListData != null
            ? HoldingList.fromJson(cachedHoldingListData)
            : null;
        if (cachedHoldingList == null) {
          emit(const GetHoldingListLoadingState());
        } else {
          emit(GetHoldingListSuccessState(holdingList: cachedHoldingList));
        }
      } else {
        emit(const GetHoldingListLoadingState());
      }

      try {
        HoldingList response = await homeRepo.getHoldings();
        if (currentUserId != null) {
          await cacheData(
              prefs, 'cachedHoldingList', response.toJson(), currentUserId);
        }
        emit(GetHoldingListSuccessState(holdingList: response));
      } catch (error) {
        _handleError(error, emit);
      }
    });

    on<GetHoldingByIdEvent>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = await TokenService.getJWTToken();

      // Try to load cached data
      if (currentUserId != null && event.useCache) {
        final cachedHoldingData = readCachedData(
            prefs, 'cachedHoldingData_${event.id}', currentUserId,
            ageLimit: const Duration(hours: 12));

        // Deserialize data if available
        Holding? cachedHolding = cachedHoldingData != null
            ? Holding.fromJson(cachedHoldingData)
            : null;

        if (cachedHolding == null) {
          emit(const GetHoldingByIdLoadingState());
        } else {
          emit(GetHoldingByIdSuccessState(holding: cachedHolding));
        }
      } else {
        emit(const GetHoldingByIdLoadingState());
      }

      try {
        Holding response = await homeRepo.getHoldingById(event.id);

        // Cache new data with timestamps
        if (currentUserId != null) {
          await cacheData(prefs, 'cachedHoldingData_${event.id}',
              response.toJson(), currentUserId);
        }

        emit(GetHoldingByIdSuccessState(holding: response));
      } catch (error) {
        _handleError(error, emit);
      }
    });

    on<GetPortfolioValueEvent>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = await TokenService.getJWTToken();
      // Try to load cached data
      if (currentUserId != null && event.useCache) {
        final cachedCashBalanceData = readCachedData(
            prefs, 'cachedCashBalance', currentUserId,
            ageLimit: null);

        // Deserialize data if available
        CashBalance? cachedCashBalance = cachedCashBalanceData != null
            ? CashBalance.fromJson(cachedCashBalanceData)
            : null;

        if (cachedCashBalance == null) {
          emit(const GetPortfolioValueLoadingState());
        } else {
          emit(
              GetPortfolioValueSuccessState(portfolioValue: cachedCashBalance));
        }
      } else {
        emit(const GetPortfolioValueLoadingState());
      }

      try {
        CashBalance response = await homeRepo.getPortfolioValue();
        if (currentUserId != null) {
          await cacheData(
              prefs, 'cachedCashBalance', response.toJson(), currentUserId);
        }

        emit(GetPortfolioValueSuccessState(portfolioValue: response));
      } catch (error) {
        _handleError(error, emit);
      }
    });

    on<GetInterestSummaryStatusEvent>((event, emit) async {
      emit(const HomeState(status: HomeStateStatus.loading));
      try {
        bool response = await homeRepo.checkInterstSummaryActive();
        emit(GetInterestSummaryStatusSuccessState(
            interestSummaryActive: response));
      } catch (error) {
        _handleError(error, emit);
      }
    });

    on<SubmitUserVerificationEvent>((event, emit) async {
      emit(const SubmitUserVerificationLoadingState());
      try {
        UserVerification response = await homeRepo.submit(event.userAgreements,
            event.viewedTimestamp, event.signedTimestamp, event.endUserIp);
        final prefs = await SharedPreferences.getInstance();
        invalidateCache(prefs, 'cachedUserInfo');
        emit(SubmitUserVerificationSuccessState(verification: response));
      } catch (error) {
        _handleError(error, emit);
      }
    });

    on<UpdateNameEvent>((event, emit) async {
      emit(const UpdateNameLoadingState());
      try {
        UserInfo response = await homeRepo.updateName(
            event.firstName, event.middleName, event.lastName);
        emit(UpdateNameSuccessState(userInfo: response));
      } catch (error) {
        _handleError(error, emit);
      }
    });

    on<UpdateDOBEvent>((event, emit) async {
      emit(const UpdateDOBLoadingState());
      try {
        UserInfo response = await homeRepo.updateDOB(event.dateOfBirth);
        emit(UpdateDOBSuccessState(userInfo: response));
      } catch (error) {
        _handleError(error, emit);
      }
    });

    on<UpdateTaxIDEvent>((event, emit) async {
      emit(const UpdateTaxIdLoadingState());
      try {
        UserInfo response = await homeRepo.updateTaxId(event.taxID);
        emit(UpdateTaxIdSuccessState(userInfo: response));
      } catch (error) {
        _handleError(error, emit);
      }
    });

    on<UpdateAddressEvent>((event, emit) async {
      emit(const UpdateAddressLoadingState());
      try {
        UserInfo response = await homeRepo.updateAddress(
            event.countryCode,
            event.street,
            event.additional,
            event.city,
            event.region,
            event.postalCode,
            event.countryOfTaxResidence,
            event.stateOfTaxResidence);
        emit(UpdateAddressSuccessState(userInfo: response));
      } catch (error) {
        _handleError(error, emit);
      }
    });

    on<UpdatePersonalDetailsEvent>((event, emit) async {
      emit(const UpdatePersonalDetailsLoadingState());
      try {
        UserInfo response = await homeRepo.updatePersonalDetails(
            event.dateOfBirth,
            event.countryCode,
            event.street,
            event.additional,
            event.city,
            event.region,
            event.postalCode,
            event.countryOfCitizenship,
            event.countryOfTaxResidence,
            event.stateOfTaxResidence,
            event.residenceStatus,
            event.taxID);
        emit(UpdatePersonalDetailsSuccessState(userInfo: response));
      } catch (error) {
        _handleError(error, emit);
      }
    });

    on<UpdateEmploymentInfoEvent>((event, emit) async {
      emit(const UpdateEmploymentInfoLoadingState());
      try {
        UserInfo response = await homeRepo.updateEmploymentInformation(
            event.employmentStatus,
            event.employerName,
            event.occupation,
            event.occupationIndustry,
            event.isFinraAffiliated,
            event.isControlPublicCompany,
            event.isPoliticallyExposed,
            event.isFamilyPoliticallyExposed,
            event.affiliatedExchange,
            event.controlCorporation);
        emit(UpdateEmploymentInfoSuccessState(userInfo: response));
      } catch (error) {
        _handleError(error, emit);
      }
    });

    on<UpdateFinancialProfileEvent>((event, emit) async {
      emit(const UpdateFinancialProfileLoadingState());
      try {
        UserInfo response = await homeRepo.updateFinancialProfile(
            event.investmentPriority,
            event.investmentHorizon,
            event.downturnReaction,
            event.annualIncome,
            event.netWorth);
        emit(UpdateFinancialProfileSuccessState(userInfo: response));
      } catch (error) {
        _handleError(error, emit);
      }
    });

    on<GetAddressSuggestionsEvent>((event, emit) async {
      List<dynamic> response = await homeRepo.getSuggestion(event.input);
      emit(SearchAddressSuccessState(suggestions: response));
    });

    on<CreateSellEvent>((event, emit) async {
      emit(const CreateSellLoadingState());
      try {
        Holding response = await homeRepo.createSellTrade(
            event.amount, event.cusip, event.duration);

        final prefs = await SharedPreferences.getInstance();
        final currentUserId = await TokenService.getJWTToken();
        // Cache new data with timestamps
        if (currentUserId != null) {
          await cacheData(prefs, 'cachedHoldingData_${event.id}',
              response.toJson(), currentUserId);
        }

        emit(CreateSellSuccessState(amount: event.amount, holding: response));
      } catch (error) {
        _handleError(error, emit);
      }
    });

    on<ToggleAutoRollEvent>((event, emit) async {
      emit(const HomeState(status: HomeStateStatus.loading));
      try {
        await homeRepo.toggleAutoRoll(event.holdingId, event.autoRollEnabled);
        final prefs = await SharedPreferences.getInstance();
        invalidateCache(prefs, 'cachedHoldingData_${event.holdingId}');
        emit(
            ToggleAutoRollSuccessState(autoRollEnabled: event.autoRollEnabled));
      } catch (error) {
        _handleError(error, emit);
      }
    });

    on<ChangePasswordEvent>(((event, emit) async {
      emit(const ChangePasswordLoadingState());
      try {
        await homeRepo.changePassword(event.oldPassword, event.newPassword);
        emit(const ChangePasswordSuccessState());
      } catch (error) {
        _handleError(error, emit);
      }
    }));

    on<RequestAccountClosureEvent>(((event, emit) async {
      emit(const RequestAccountClosureLoadingState());
      try {
        await homeRepo.requestAccountClosure();
        emit(const RequestAccountClosureSuccessState());
      } catch (error) {
        _handleError(error, emit);
      }
    }));

    on<SubmitVerificationInfoEvent>(((event, emit) async {
      emit(const SubmitVerificationInfoLoadingState());
      try {
        await homeRepo.submitVerificationInfo(event.userInput);
        final prefs = await SharedPreferences.getInstance();
        invalidateCache(prefs, 'cachedUserInfo');
        emit(const SubmitVerificationInfoSuccessState());
      } catch (error) {
        _handleError(error, emit);
      }
    }));

    on<SendSupportRequestEvent>(((event, emit) async {
      emit(const SendSupportRequestLoadingState());
      try {
        await homeRepo.sendSupportRequest(event.supportQuery);
        emit(const SendSupportRequestSuccessState());
      } catch (error) {
        _handleError(error, emit);
      }
    }));

    on<MissingReferralRequestEvent>(((event, emit) async {
      emit(const MissingReferralRequestLoadingState());
      try {
        await homeRepo.sendMissingReferralRequest(event.missingReferralEmail);
        emit(const MissingReferralRequestSuccessState());
      } catch (error) {
        _handleError(error, emit);
      }
    }));

    on<CheckReferralProgramStatusEvent>(((event, emit) async {
      emit(const HomeState(status: HomeStateStatus.loading));
      try {
        bool active = await homeRepo.checkReferralProgramActive();
        emit(CheckReferralProgramStatusSuccessStatus(active: active));
      } catch (error) {
        _handleError(error, emit);
      }
    }));

    on<GetReferralBonusValueEvent>(((event, emit) async {
      emit(const HomeState(status: HomeStateStatus.loading));
      try {
        String referralBonus = await homeRepo.getReferralBonusValue();
        emit(GetReferralBonusValueSuccessState(referralBonus: referralBonus));
      } catch (error) {
        _handleError(error, emit);
      }
    }));

    on<LoadInAppNotifications>((event, emit) async {
      emit(const HomeState(status: HomeStateStatus.loading));
      try {
        InAppNotificationList notifications =
            await homeRepo.getInAppNotificationList();
        emit(
            LoadInAppNotificationSuccessState(notificationList: notifications));
      } catch (error) {
        _handleError(error, emit);
      }
    });

    on<MarkNotificationAsProcessed>((event, emit) async {
      emit(const HomeState(status: HomeStateStatus.loading));
      try {
        await homeRepo.markNotificationAsProcessed(event.id);
        emit(const MarkNotificationAsProcessedSuccessState());
      } catch (error) {
        _handleError(error, emit);
      }
    });

    on<LoadHomeScreenInitialDataEvent>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = await TokenService.getJWTToken();

      // Try to load cached data
      if (currentUserId != null && event.useCache) {
        final cachedCashBalanceData =
            readCachedData(prefs, 'cachedCashBalance', currentUserId);
        final cachedUserInfoData =
            readCachedData(prefs, 'cachedUserInfo', currentUserId);
        final cachedTransactionListData =
            readCachedData(prefs, 'cachedTransactionList', currentUserId);
        final cachedHoldingListData =
            readCachedData(prefs, 'cachedHoldingList', currentUserId);
        final cachedInterestSummaryStatusData =
            readCachedData(prefs, 'cachedInterestSummaryStatus', currentUserId);

        // Deserialize data if available
        CashBalance? cachedCashBalance = cachedCashBalanceData != null
            ? CashBalance.fromJson(cachedCashBalanceData)
            : null;
        UserInfo? cachedUserInfo = cachedUserInfoData != null
            ? UserInfo.fromJson(cachedUserInfoData)
            : null;
        TransactionList? cachedTransactionList =
            cachedTransactionListData != null
                ? TransactionList.fromJson(cachedTransactionListData)
                : null;
        HoldingList? cachedHoldingList = cachedHoldingListData != null
            ? HoldingList.fromJson(cachedHoldingListData)
            : null;
        bool? cachedInterestSummaryStatus = cachedInterestSummaryStatusData;

        // If any cached data is missing or outdated, emit loading and fetch data
        if (cachedCashBalance == null ||
            cachedUserInfo == null ||
            cachedTransactionList == null ||
            cachedHoldingList == null ||
            cachedInterestSummaryStatus == null) {
          emit(const LoadHomeScreenInitialLoadingState());
        } else {
          // Emit success with cached data
          emit(LoadHomeScreenInitialSuccessState(
              portfolioValue: cachedCashBalance,
              userInfo: cachedUserInfo,
              transactionList: cachedTransactionList,
              holdingList: cachedHoldingList,
              interestSummaryActive: cachedInterestSummaryStatus));
        }
      } else {
        emit(const LoadHomeScreenInitialLoadingState());
      }

      try {
        final futureCashBalance = homeRepo.getPortfolioValue();
        final futureUserInfo = homeRepo.getUserInformation();
        final futureTransactionList = homeRepo.getTransactionList();
        final futureHoldingList = homeRepo.getHoldings();
        final futureInterestSummaryStatus =
            homeRepo.checkInterstSummaryActive();

        final results = await Future.wait([
          futureCashBalance,
          futureUserInfo,
          futureTransactionList,
          futureHoldingList,
          futureInterestSummaryStatus
        ]);

        CashBalance newCashBalance = results[0] as CashBalance;
        UserInfo newUserInfo = results[1] as UserInfo;
        TransactionList newTransactionList = results[2] as TransactionList;
        HoldingList newHoldingList = results[3] as HoldingList;
        bool interestSummaryStatus = results[4] as bool;

        // Cache new data with timestamps
        if (currentUserId != null) {
          await cacheData(prefs, 'cachedCashBalance', newCashBalance.toJson(),
              currentUserId);
          await cacheData(
              prefs, 'cachedUserInfo', newUserInfo.toJson(), currentUserId);
          await cacheData(prefs, 'cachedTransactionList',
              newTransactionList.toJson(), currentUserId);
          await cacheData(prefs, 'cachedHoldingList', newHoldingList.toJson(),
              currentUserId);
          await cacheData(prefs, 'cachedInterestSummaryStatus',
              interestSummaryStatus, currentUserId);
        }

        emit(LoadHomeScreenInitialSuccessState(
            portfolioValue: newCashBalance,
            userInfo: newUserInfo,
            transactionList: newTransactionList,
            holdingList: newHoldingList,
            interestSummaryActive: interestSummaryStatus));
      } catch (error) {
        _handleError(error, emit);
      }
    });

    on<LoadProfileScreenInitialDataEvent>(((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = await TokenService.getJWTToken();

      // Try to load cached data
      if (currentUserId != null && event.useCache) {
        final cachedUserInfoData =
            readCachedData(prefs, 'cachedUserInfo', currentUserId);
        final cachedReferralProgramStatusData =
            readCachedData(prefs, 'cachedReferralProgramStatus', currentUserId);

        // Deserialize data if available
        UserInfo? cachedUserInfo = cachedUserInfoData != null
            ? UserInfo.fromJson(cachedUserInfoData)
            : null;
        bool? cachedReferralStatus = cachedReferralProgramStatusData;

        if (cachedUserInfo == null || cachedReferralStatus == null) {
          emit(const LoadProfileScreenInitialLoadingState());
        } else {
          emit(LoadProfileScreenInitialSuccessState(
              userInfo: cachedUserInfo, active: cachedReferralStatus));
        }
      } else {
        emit(const LoadProfileScreenInitialLoadingState());
      }

      try {
        final futureUserInfo = homeRepo.getUserInformation();
        final futureReferralProgramStatus =
            homeRepo.checkReferralProgramActive();

        final results =
            await Future.wait([futureUserInfo, futureReferralProgramStatus]);
        UserInfo userInfo = results[0] as UserInfo;
        bool active = results[1] as bool;

        // Cache new data with timestamps
        if (currentUserId != null) {
          await cacheData(
              prefs, 'cachedUserInfo', userInfo.toJson(), currentUserId);
          await cacheData(
              prefs, 'cachedReferralProgramStatus', active, currentUserId);
        }

        emit(LoadProfileScreenInitialSuccessState(
            userInfo: userInfo, active: active));
      } catch (error) {
        _handleError(error, emit);
      }
    }));

    on<LoadReferralScreenInitialDataEvent>(((event, emit) async {
      emit(const LoadReferralScreenInitialLoadingState());
      try {
        ReferralInfo referralInfo = await homeRepo.getReferralInfo();
        if (referralInfo.referralCode == null) {
          throw ApiException(ErrorCodes.INVALID_RESPONSE,
              "Response doesn't contain referral code");
        }
        emit(LoadReferralScreenInitialSuccessState(referralInfo: referralInfo));
      } catch (error) {
        _handleError(error, emit);
      }
    }));
  }
}
