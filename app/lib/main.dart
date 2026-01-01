import "package:app/provider/user_provider.dart";
import "package:app/screens/splash_screen.dart";
import "package:flutter/material.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:provider/provider.dart";

Future<void> main() async {
  await dotenv.load();
  runApp(ChangeNotifierProvider(create: (_) => UserProvider(), child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: SplashScreen());
  }
}
