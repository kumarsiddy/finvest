import 'package:finvest/presentation/core_app/base/base_view_controller.dart';
import 'package:injectable/injectable.dart';

@injectable
class HomePageViewController extends BaseViewController {
  int selectedIndex = 0;
  int selectedTabIndex = 3;

  @override
  Future<void> dispose() async {}

  @override
  Future<void> init() async {}
}
