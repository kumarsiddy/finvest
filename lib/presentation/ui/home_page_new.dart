import 'package:bondgrid/presentation/base/base_bloc.dart';
import 'package:bondgrid/presentation/base/common_bloc.dart';
import 'package:bondgrid/presentation/ui/base/base_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

class NewHomePage extends StatefulWidget {
  const NewHomePage({super.key});

  @override
  State<StatefulWidget> createState() => _NewHomePageState();
}

class _NewHomePageState extends BaseState<NewHomePage> {
  @override
  Widget buildWidget(BuildContext context) {
    final bloc = BlocProvider.of<NewHomePageBloc>(context);
    final bloc2 = BlocProvider.of<CommonBloc>(context);
    final bloc3 = BlocProvider.of<NewHomePageBloc2>(context);
    final bloc4 = BlocProvider.of<NewHomePageBloc3>(context);

    print(bloc != null);
    print(bloc2 != null);
    print(bloc3 != null);
    print(bloc4 != null);

    return Container(
      child: Column(
        children: [NewPage()],
      ),
    );
  }

  @override
  List<BlocProvider> getBlocProviders() {
    return [
      createBlocProvider<NewHomePageBloc>(isMain: true),
      createBlocProvider<NewHomePageBloc2>(),
      createBlocProvider<NewHomePageBloc3>(),
    ];
  }
}

class NewPage extends StatelessWidget {
  const NewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommonBloc, CommonState>(builder: (ctx, state) {
      if (state.store.loading) {
        print('loader is showing');
        return SizedBox.shrink();
      }
      if(!state.store.loading) {
        print('loader is hidden');
      }
      return SizedBox.shrink();

    });
  }
}

@injectable
class NewHomePageBloc extends BaseBloc<NewHomePageEvent, NewHomePageState> {
  NewHomePageBloc() : super(NewHomePageState());

  @override
  void handleEvents() {}

  @override
  void init() {
    super.init();

    showLoader();

    hideLoader();
  }
}

class NewHomePageEvent {}

class NewHomePageState {}

@injectable
class NewHomePageBloc2 extends BaseBloc<NewHomePageEvent, NewHomePageState> {
  NewHomePageBloc2() : super(NewHomePageState());

  @override
  void handleEvents() {}

  void methodToGetData() {
    showLoader();

    hideLoader();
  }
}

@injectable
class NewHomePageBloc3 extends BaseBloc<NewHomePageEvent, NewHomePageState> {
  NewHomePageBloc3() : super(NewHomePageState());

  @override
  void handleEvents() {}

  void methodToGetData() {
    showLoader();

    hideLoader();
  }
}
