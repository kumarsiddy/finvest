import 'package:bondgrid/enums/residence_status.dart';

class PersonalDetails {
  String? email;
  String? firstName;
  String? middleName;
  String? lastName;

  String? phoneNumber;
  String? dateOfBirth;

  String? countryCode;
  String? street;
  String? additional;
  String? city;
  String? region;
  String? postalCode;

  List<String>? countryOfCitizenship;
  String? countryOfTaxResidence;
  String? stateOfTaxResidence;

  ResidenceStatus? residenceStatus;

  String? taxID;

  PersonalDetails();

  PersonalDetails.fromParams(
      this.email,
      this.firstName,
      this.middleName,
      this.lastName,
      this.phoneNumber,
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

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth,
      'countryCode': countryCode,
      'street': street,
      'additional': additional,
      'city': city,
      'region': region,
      'postalCode': postalCode,
      'countryOfCitizenship': countryOfCitizenship,
      'countryOfTaxResidence': countryOfTaxResidence,
      'stateOfTaxResidence': stateOfTaxResidence,
      'residenceStatus': residenceStatus?.value,
      'taxID': taxID,
    };
  }

  PersonalDetails.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    firstName = json['firstName'];
    middleName = json['middleName'];
    lastName = json['lastName'];
    phoneNumber = json['phoneNumber'];
    dateOfBirth = json['dateOfBirth'];
    countryCode = json['countryCode'];
    street = json['street'];
    additional = json['additional'];
    city = json['city'];
    region = json['region'];
    postalCode = json['postalCode'];
    countryOfCitizenship = _stringListFromJson(json['countryOfCitizenship']);
    countryOfTaxResidence = json['countryOfTaxResidence'];
    stateOfTaxResidence = json['stateOfTaxResidence'];
    residenceStatus = json['residenceStatus'] != null
        ? ResidenceStatus.values
            .firstWhere((e) => e.value == json['residenceStatus'])
        : null;
    taxID = json['taxID'];
  }

  bool isComplete() {
    return [
      dateOfBirth,
      postalCode,
      countryOfCitizenship,
      countryOfTaxResidence,
      stateOfTaxResidence,
      residenceStatus
    ].every((element) => element != null);
  }

  List<String> _stringListFromJson(List<dynamic>? jsonList) {
    return jsonList?.map((item) => item.toString()).toList() ?? [];
  }

  String formatAddress() {
    List<String> addressLines = [];

    if (street != null && street!.isNotEmpty) {
      addressLines.add(street!);
    }

    if (additional != null && additional!.isNotEmpty) {
      addressLines.add(additional!);
    }

    String cityRegionPostal = '';
    if (city != null && city!.isNotEmpty) {
      cityRegionPostal += city!;
    }
    if (region != null && region!.isNotEmpty) {
      if (cityRegionPostal.isNotEmpty) cityRegionPostal += ', ';
      cityRegionPostal += region!;
    }
    if (postalCode != null && postalCode!.isNotEmpty) {
      if (cityRegionPostal.isNotEmpty) cityRegionPostal += ' ';
      cityRegionPostal += postalCode!;
    }
    if (cityRegionPostal.isNotEmpty) {
      addressLines.add(cityRegionPostal);
    }

    return addressLines.join('\n');
  }
}
