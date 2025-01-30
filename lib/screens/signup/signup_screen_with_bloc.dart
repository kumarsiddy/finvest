import 'package:bondgrid/bloc/authentication_bloc.dart';
import 'package:bondgrid/repo/authentication_repo.dart';
import 'package:bondgrid/screens/authentication/name_signup_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupDetailsScreenBloc extends StatelessWidget {
  const SignupDetailsScreenBloc({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (BuildContext context) =>
            AuthenticationBloc(AuthenticationRepo()),
        child: const NameSignupForm());
  }
}
