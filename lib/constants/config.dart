class ConfigurationFile {
  // static String baseUrl = "http://10.0.2.2:8080";
  // static String baseUrl = "http://localhost:8080";
  // static String baseUrl = "https://finvestbackend.com";
  static String baseUrl = "https://finvest-prod.com";
  // static String baseUrl =
  //     "http://finvest-prod.eba-84qxnqgk.us-east-2.elasticbeanstalk.com";
  // static String baseUrl =
  //     "http://finvest-dev.eba-84qxnqgk.us-east-2.elasticbeanstalk.com"; // finvest-dev backend

  // Auth Endpoints
  static String register = "$baseUrl/api/v1/auth/register";
  static String verifyEmailOtp = "$baseUrl/api/v1/auth/verify-email-otp";
  static String generatePhoneOTP = "$baseUrl/api/v1/auth/generate-phone-otp";
  static String verifyPhoneOTP = "$baseUrl/api/v1/auth/verify-phone-otp";

  static String login = "$baseUrl/api/v1/auth/login";
  static String verifyLoginOTP = "$baseUrl/api/v1/auth/verify-login-otp";

  static String resendOTP = "$baseUrl/api/v1/auth/resend-otp";
  static String renewToken = "$baseUrl/api/v1/auth/renew-token";
  static String forgotPassword = "$baseUrl/api/v1/auth/forgot-password";

  static String changePassword = "$baseUrl/api/v1/auth/change-password";

  static String displayedInterestRate =
      "$baseUrl/api/v1/utilities/get-displayed-interest-rate";

  // User Profile Endpoints
  static String updateName = "$baseUrl/api/v1/identity/update-name";
  static String updateDOB = "$baseUrl/api/v1/identity/update-dob";
  static String updateTaxId = "$baseUrl/api/v1/identity/update-taxId";
  static String updateAddress = "$baseUrl/api/v1/identity/update-address";
  static String updatePersonalDetails =
      "$baseUrl/api/v1/identity/personal-details";
  static String updateEmploymentInformation =
      "$baseUrl/api/v1/identity/employment-information";
  static String updateFinancialProfile =
      "$baseUrl/api/v1/identity/financial-profile";
  static String addPushNotificationToken =
      "$baseUrl/api/v1/services/add-push-notification-token";
  static String addPushNotificationTokenAtRegistration =
      "$baseUrl/api/v1/services/add-push-notification-token-at-registration";
  static String deletePushNotificationTokenAtSignout =
      "$baseUrl/api/v1/services/delete-push-notification-token";

  static String checkIfInterestSummaryActive =
      "$baseUrl/api/v1/utilities/check-if-interest-summary-active";

  static String getUserInformation = "$baseUrl/api/v1/get-user-information";
  static String getUserStatus = "$baseUrl/api/v1/get-user-status";
  static String getUserAgreements = "$baseUrl/api/v1/get-user-agreements";
  static String submit = "$baseUrl/api/v1/identity/submit";
  static String requestAccountClosure =
      "$baseUrl/api/v1/identity/request-account-closure";

  static String getPlaidLinkToken =
      "$baseUrl/api/v1/services/create-plaid-link-token";
  static String exchangePlaidPublicToken =
      "$baseUrl/api/v1/services/exchange-plaid-public-token";

  static String getPaymentMethods =
      "$baseUrl/api/v1/services/list-payment-methods";
  static String deletePaymentMethod =
      "$baseUrl/api/v1/services/delete-payment-method";

  static String createDeposit = "$baseUrl/api/v1/services/create-deposit";
  static String createWithdrawal = "$baseUrl/api/v1/services/create-withdrawal";

  static String getPortfolioValue =
      "$baseUrl/api/v1/services/get-portfolio-value";
  static String getOnlyBuyingPower =
      "$baseUrl/api/v1/services/get-only-buying-power";
  static String getBuyingPower = "$baseUrl/api/v1/services/get-buying-power";

  static String listAssets = "$baseUrl/api/v1/utilities/list-assets";

  static String purchaseTreasuryBill =
      "$baseUrl/api/v1/trading/purchase-treasury-bill";
  static String sellTreasuryBill = "$baseUrl/api/v1/trading/sell-treasury-bill";

  static String toggleHoldingAutoRoll =
      "$baseUrl/api/v1/trading/toggle-holding-auto-roll";

  static String getTransactionActivity =
      "$baseUrl/api/v1/services/get-activity";
  static String getHoldingById = "$baseUrl/api/v1/services/get-holding";
  static String listHoldings = "$baseUrl/api/v1/services/list-holdings";
  static String listPendingTrades =
      "$baseUrl/api/v1/services/list-pending-trades";

  static String getNotificationPreferences =
      "$baseUrl/api/v1/services/get-notification-preferences";
  static String updateNotificationPreferences =
      "$baseUrl/api/v1/services/update-notification-preferences";

  static String listDocuments = "$baseUrl/api/v1/services/list-documents";
  static String getDocumentById = "$baseUrl/api/v1/services/get-document";

  static String submitVerificationInfo =
      "$baseUrl/api/v1/services/submit-info-for-verification";
  static String sendSupportRequest = "$baseUrl/api/v1/services/support-request";
  static String sendMissingReferralRequest =
      "$baseUrl/api/v1/services/missing-referral-request";

  static String getReferralInfo = "$baseUrl/api/v1/services/get-referral-info";
  static String checkIfReferralProgramActive =
      "$baseUrl/api/v1/utilities/check-if-referral-program-active";
  static String getReferralBonusValue =
      "$baseUrl/api/v1/utilities/get-referral-bonus-value";

  static String googleAutocompleteUrl =
      "https://maps.googleapis.com/maps/api/place/autocomplete/json";
  static String googleAutocompleteApiKey =
      "AIzaSyBuUvnKoIH8vqnreOQ2kVvFC8G3whQ3Sv4";
  static String googlePlacesUrl =
      "https://maps.googleapis.com/maps/api/place/details/json";

  static String getInAppNotifications =
      "$baseUrl/api/v1/services/get-inapp-notifications";
  static String markInAppNotificationAsProcessed =
      "$baseUrl/api/v1//services/mark-inapp-notification-processed";
}
