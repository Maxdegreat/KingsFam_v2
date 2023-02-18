import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/repositories/repositories.dart';

import 'package:kingsfam/screens/loginForm/cubit/loginform_cubit.dart';
import 'package:kingsfam/widgets/widgets.dart';

class LoginFormScren extends StatelessWidget {
  static const String routeName = '/LoginFormScreen';
  static Route route() {
    return PageRouteBuilder(
        settings: const RouteSettings(name: routeName),
        transitionDuration: const Duration(seconds: 0),
        pageBuilder: (
          context,
          __,
          ___,
        ) =>
            BlocProvider<LoginformCubit>(
              create: (_) => LoginformCubit(
                  authRepository: context.read<AuthRepository>()),
              child: LoginFormScren(),
            ));
  }

  final _loginFormKey = GlobalKey<FormState>();
//String? _name;
 // String? _email;
 // String? _password;

  _loginForm(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width > 700 ? size.width / 7: size.width / 1.2,
      child: Form(
        key: _loginFormKey,
        child: Column(
          children: [
            _buildEmailTF(context),
            _buildPasswordTF(context),
          ],
        ),
      ),
    );
  }

  _buildEmailTF(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: TextFormField(
          decoration: const InputDecoration(labelText: 'Email'),
          onChanged: (value) =>
              context.read<LoginformCubit>().emailChanged(value),
          validator: (input) =>
              !input!.contains('@') ? 'Please enter a valid email' : null,
         // onSaved: (input) => _email = input!),
    ));
  }

  _buildPasswordTF(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: TextFormField(
          decoration: const InputDecoration(labelText: 'Password'),
          onChanged: (value) =>
              context.read<LoginformCubit>().passwordChanged(value),
          validator: (input) =>
              input!.length < 7 ? 'Password must contain 7 characters' : null,
          //onSaved: (input) => _password = input!),
    ));
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return BlocConsumer<LoginformCubit, LoginformState>(
      //lisitener is used for navigation
      listener: (context, state) {
        if (state.status == LoginStatus.error) {
          //showDialog
          showDialog(
              context: context,
              builder: (context) => ErrorDialog(
                    content: state.failure.message,
                  ));
        }
      },
      //buillder is used for UI
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
              centerTitle: true,
              title: Text('Welcome Back Fam',
                  style: Theme.of(context).textTheme.headline2)),
          body: SingleChildScrollView(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Center(
                  child: Column(children: [
                //  SizedBox(height: 20.0),
                //     Text('Hebrews 13:2',
                //         style: Theme.of(context).textTheme.headline2),
                SizedBox(height: 20.0),
                _loginForm(context),
                SizedBox(height: 40),
                Center(
                  child: Container(
                    width: size.width > 700 ? size.width / 7: size.width / 1.2,
                    child: TextButton(
                        onPressed: () => _submitForm(
                            context, state.status == LoginStatus.submitting),
                        child: Text('Continue',
                            style: Theme.of(context).textTheme.bodyText1),
                        style: TextButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary)),
                  ),
                )
              ])),
            ),
          ),
        );
      },
    );
  }

  void _submitForm(BuildContext context, bool isSubmitting) {
    if (_loginFormKey.currentState!.validate() && !isSubmitting) {
      context.read<LoginformCubit>().loginWithCredientials();
    }
  }
}
