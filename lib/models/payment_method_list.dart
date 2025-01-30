import 'package:bondgrid/enums/payment_method_status.dart';
import 'package:bondgrid/models/payment_method.dart';

class PaymentMethodList {
  List<PaymentMethod> paymentMethods = [];
  int defaultPaymentMethodIndex = -1;

  PaymentMethodList();
  PaymentMethodList.empty();

  PaymentMethodList.fromJson(Map<String, dynamic> json) {
    if (json['elements'] != null) {
      paymentMethods = List.from(json['elements'])
          .map((e) => PaymentMethod.fromJson(e))
          .toList();

      defaultPaymentMethodIndex = paymentMethods.indexWhere((method) =>
          (method.status == PaymentMethodStatus.ACTIVE ||
              method.status == PaymentMethodStatus.PENDING));
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'elements': paymentMethods
          .map((paymentMethod) => paymentMethod.toJson())
          .toList(),
    };
  }
}
