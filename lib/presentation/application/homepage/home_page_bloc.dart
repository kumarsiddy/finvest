import 'package:finvest/domain/interfaces/i_connection_aware_facade.dart';
import 'package:finvest/presentation/application/base/base_bloc.dart';
import 'package:finvest/presentation/application/models/state_stores.dart';
import 'package:injectable/injectable.dart';

part 'home_page_event.dart';
part 'home_page_state.dart';

@injectable
class HomePageBloc
    extends BaseBloc<HomePageEvent, HomePageState, HomePageStore> {
  HomePageBloc(
    IConnectionAwareFacade networkHandlerFacade,
  ) : super(
          networkHandlerFacade,
          HomePageStore(name: 'name', age: 10),
        );
}
