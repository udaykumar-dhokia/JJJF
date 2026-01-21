import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'package:app/bottom_bar.dart';
import 'package:clerk_auth/clerk_auth.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? _storedUserId;
  bool _isLoading = true;
  Directory? _documentsDirectory;

  @override
  void initState() {
    super.initState();
    _checkStoredUser();
  }

  Future<void> _saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();

    final existingId = prefs.getString("userId");
    if (existingId == null) {
      await prefs.setString('userId', userId);
    }
  }

  Future<void> _checkStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId");
    final docsDir = await getApplicationDocumentsDirectory();

    setState(() {
      _documentsDirectory = docsDir;
      _storedUserId = userId;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CupertinoActivityIndicator()));
    }

    if (_storedUserId != null) {
      return const BottomBar();
    }
    return ClerkAuth(
      persistor: DefaultPersistor(
        getCacheDirectory: () => _documentsDirectory!,
      ),
      config: ClerkAuthConfig(
        isTestMode: false,
        publishableKey: dotenv.env["CLERK_PUBLISHABLE_KEY"]!,
        loading: const Scaffold(
          body: Center(child: CupertinoActivityIndicator(color: Colors.black)),
          backgroundColor: Colors.white,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: ClerkErrorListener(
            handler: (context, error) => {
              print(error),
              const Center(child: CupertinoActivityIndicator()),
            },
            child: ClerkAuthBuilder(
              signedInBuilder: (context, authState) {
                final user = authState.user;

                if (user == null) {
                  return const Center(child: CupertinoActivityIndicator());
                }

                _saveUserId(user.id);

                return const BottomBar();
              },
              signedOutBuilder: (context, authState) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [ClerkAuthentication()],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
