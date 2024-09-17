import 'package:finvest/env.dart';
import 'package:finvest/main.dart';

Future<void> main() async {
  await mainCommon(const Env(prod));
}
