import 'package:bondgrid/enums/employment_status.dart';
import 'package:bondgrid/models/occupation.dart';
import 'package:bondgrid/models/occupation_industry.dart';

class EmploymentInformation {
  EmploymentStatus? employmentStatus;
  String? employerName;
  Occupation? occupation;
  OccupationIndustry? occupationIndustry;
  bool? isFinraAffiliated;
  bool? isControlPublicCompany;
  bool? isPoliticallyExposed;
  bool? isFamilyPoliticallyExposed;
  List<String>? affiliatedExchange;
  List<String>? controlCorporation;

  EmploymentInformation();

  EmploymentInformation.fromParams(
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

  Map<String, dynamic> toJson() {
    return {
      'employmentStatus': employmentStatus?.value,
      'employerName': employerName,
      'occupation': occupation?.value,
      'occupationIndustry': occupationIndustry?.value,
      'isFinraAffiliated': isFinraAffiliated,
      'isControlPublicCompany': isControlPublicCompany,
      'isPoliticallyExposed': isPoliticallyExposed,
      'isFamilyPoliticallyExposed': isFamilyPoliticallyExposed,
      'affiliatedExchange': affiliatedExchange,
      'controlCorporation': controlCorporation,
    };
  }

  EmploymentInformation.fromJson(Map<String, dynamic> json) {
    employmentStatus = json['employmentStatus'] != null
        ? EmploymentStatus.values
            .firstWhere((e) => e.value == json['employmentStatus'])
        : null;
    employerName = json['employerName'];
    occupation = json['occupation'] != null
        ? Occupation.findByValue(json['occupation'])
        : null;
    occupationIndustry = json['occupationIndustry'] != null
        ? OccupationIndustry.findByValue(json['occupationIndustry'])
        : null;
    isFinraAffiliated = json['isFinraAffiliated'];
    isControlPublicCompany = json['isControlPublicCompany'];
    isPoliticallyExposed = json['isPoliticallyExposed'];
    isFamilyPoliticallyExposed = json['isFamilyPoliticallyExposed'];
    affiliatedExchange = _stringListFromJson(json['affiliatedExchange']);
    controlCorporation = _stringListFromJson(json['controlCorporation']);
  }

  bool isComplete() {
    return [
      employmentStatus,
      isFinraAffiliated,
      isControlPublicCompany,
      isPoliticallyExposed,
      isFamilyPoliticallyExposed,
    ].every((element) => element != null);
  }

  List<String> _stringListFromJson(List<dynamic>? jsonList) {
    return jsonList?.map((item) => item.toString()).toList() ?? [];
  }
}
