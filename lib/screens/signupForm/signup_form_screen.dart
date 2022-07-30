import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/signupForm/cubit/signupform_cubit.dart';
import 'package:kingsfam/widgets/widgets.dart';

class SignupFormScreen extends StatelessWidget {
  static const String routeName = '/SignupFormScreen';

  static Route route() {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) => BlocProvider<SignupformCubit>(
              create: (_) => SignupformCubit(
                  authRepository: context.read<AuthRepository>()),
              child: SignupFormScreen(),
            )); //buildcontext, animaitons ;
  }

  //VARABLES
  final _signupFormKey = GlobalKey<FormState>();

  _signupForm(BuildContext context) {
    return Form(
        key: _signupFormKey,
        child: Column(
          children: [
            _buildNameTF(context),
            _buildEmailTF(context),
            _buildPasswordTF(context),
          ],
        ));
  }

  _buildNameTF(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: TextFormField(
        decoration: const InputDecoration(labelText: 'Username'),
        validator: (input) {
          if (input!.trim().isEmpty)
            return "You have to enter a username fam";
          else if (input.length > 10)
            return "Fam your username must be less than 10 chars";
          else if (input.contains('^') ||
              input.contains('^') ||
              input.contains('*') ||
              input.contains('@') ||
              input.contains('!') ||
              input.contains('%') ||
              input.contains('(') || input.contains(')')) 
              return "Fam your username can not contain: \'^'\', \'*\', \'@\', \'!'\ or \'%\', or \'()\'";
          return null;
        },
        onChanged: (value) =>
            context.read<SignupformCubit>().usernameChanged(value),
        //onSaved: (input) => _name = input!.trim(),
      ),
    );
  }

  _buildEmailTF(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: TextFormField(
          decoration: const InputDecoration(labelText: 'Email'),
          validator: (input) =>
              !input!.contains('@') ? 'Please enter a valid email' : null,
          onChanged: (value) =>
              context.read<SignupformCubit>().emailChanged(value),
          //onSaved: (input) => _email = input!),
        ));
  }

  _buildPasswordTF(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: TextFormField(
          decoration: const InputDecoration(labelText: 'Password'),
          validator: (input) =>
              input!.length < 7 ? 'Password must contain 7 characters' : null,
          onChanged: (value) =>
              context.read<SignupformCubit>().passwordChanged(value),
          //onSaved: (input) => _password = input!),
        ));
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return BlocConsumer<SignupformCubit, SignupformState>(
      listener: (context, state) {
        //listens for navigation
        if (state.status == SignupStatus.error) {
          //show error text
          showDialog(
              context: context,
              builder: (context) => ErrorDialog(
                    content: state.failure.message,
                  ));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
              centerTitle: true,
              title: Text('Sign UP',
                  style: Theme.of(context).textTheme.headline2)),
          body: SingleChildScrollView(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Center(
                  child: Column(children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(children: [
                      SizedBox(height: 20.0),
                      Text('Create An Account',
                          style: Theme.of(context).textTheme.headline2),
                      Container(
                        width: 200,
                        child: Text(
                          'The Username you select will be displayed to other users',
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      ),
                    ]),
                  ),
                ),
                _signupForm(context),
                SizedBox(height: 40),
                Center(
                  child: Container(
                    width: size.width * .7,
                    child: TextButton(
                        onPressed: () => _submitForm(
                            context,
                            //will be used to prevent spam of btn
                            state.status == SignupStatus.submiting),
                        child: Text('Continue',
                            style: Theme.of(context).textTheme.bodyText1),
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.red[400])),
                  ),
                )
              ])),
            ),
          ),
        );
      },
    );
  }

  void _submitForm(
    BuildContext ayeYOOO,
    bool isSubmiting,
  ) {
    final username = ayeYOOO.read<SignupformCubit>().state.username;
    if (_signupFormKey.currentState!.validate() && !isSubmiting) {
      ayeYOOO.read<SignupformCubit>().signUpWithCredientials();
      //  StreamBuilder(
      //    stream: FirebaseFirestore.instance
      //        .collection(Paths.usernameSet)
      //        .where('username', isEqualTo: username)
      //        .snapshots(),
      //    builder: (BuildContext ayeYOOO, AsyncSnapshot<QuerySnapshot> snapshot) {
      //      if (snapshot.data!.docs.isNotEmpty) {
      //        print("username is taken");
      //        ayeYOOO.read<SignupformCubit>().onUsernameIsTaken();
      //        return Card(child: Center(child: Text("Username is taken")),);
      //      } else {
      //        print("success");
      //        ayeYOOO.read<SignupformCubit>().signUpWithCredientials();
      //        return Card(child: Center(child: Text("success")),);
      //      }
      //    },
      //  );
    }
  }
}
