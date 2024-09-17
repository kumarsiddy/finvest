import 'package:finvest/presentation/application/base/base_bloc.dart';
import 'package:injectable/injectable.dart';

part 'home_page_event.dart';
part 'home_page_state.dart';

@injectable
class HomePageBloc extends BaseBloc {
  HomePageBloc(super.networkHandlerFacade);
}
