import 'package:budget_tracker/pages/page_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {

          return RegisterScreen(
            //showAuthActionSwitch: false,
            headerBuilder: (context, constraints, _) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                      'https://firebase.flutter.dev/img/flutterfire_300x.png'),
                ),
              );
            },
            subtitleBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  action == AuthAction.signIn
                      ? 'Welcome to Budget Tracker! Please sign in to continue.'
                      : 'Welcome to Budget Tracker! Please create an account to continue.',
                ),
              );
            },
            footerBuilder: (context, _) {
              return const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'By signing in, you agree to our terms and conditions.',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            },
            providerConfigs: [
              GoogleProviderConfiguration(clientId: ''),
              PhoneProviderConfiguration(),
              EmailProviderConfiguration(
                actionCodeSettings: ActionCodeSettings(
                  url: 'https://budgettracker.page.link',
                  handleCodeInApp: true,
                  androidMinimumVersion: '21',
                  androidPackageName: 'com.bundle.id',
                  iOSBundleId: 'com.bundle.id',
                ),
              ),
              //FacebookProviderConfiguration(clientId: clientId)
            ],
          );

        }

        // Render your application if authenticated
        return RootApp();
      },
    );
  }
}
