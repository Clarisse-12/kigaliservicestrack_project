import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

import 'providers/auth_provider.dart';
import 'providers/listing_provider.dart';

import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/add_listing_screen.dart';
import 'screens/edit_listing_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ListingProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kigali Services & Places Directory',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1F3A93),
        ),
        useMaterial3: true,
      ),

      home: const _RootScreen(),

      routes: {
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/home': (_) => const HomeScreen(),
        '/add-listing': (_) => const AddListingScreen(),
      },

      onGenerateRoute: (settings) {
        if (settings.name == '/detail') {
          final listingId = settings.arguments as String;

          return MaterialPageRoute(
            builder: (_) => DetailScreen(listingId: listingId),
          );
        }

        if (settings.name == '/edit-listing') {
          final listingId = settings.arguments as String;

          return MaterialPageRoute(
            builder: (_) => EditListingScreen(listingId: listingId),
          );
        }

        return null;
      },
    );
  }
}

class _RootScreen extends StatelessWidget {
  const _RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {

        
        if (authProvider.currentUser == null) {
          return const LoginScreen();
        }

        
        if (!authProvider.isEmailVerified) {
          return _EmailVerificationScreen();
        }

        
        return const HomeScreen();
      },
    );
  }
}

class _EmailVerificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Email Verification")),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Icon(
              Icons.email_outlined,
              size: 80,
              color: Colors.blue,
            ),

            const SizedBox(height: 20),

            const Text(
              "Verify Your Email",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              "A verification email was sent to\n${authProvider.currentUser?.email}",
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            
            ElevatedButton(
              onPressed: () async {

                await authProvider.currentUser?.reload();

                if (authProvider.currentUser!.emailVerified) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Email verified successfully"),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Email not verified yet"),
                    ),
                  );
                }
              },
              child: const Text("I Have Verified My Email"),
            ),

            const SizedBox(height: 10),

          
            TextButton(
              onPressed: () {
                authProvider.resendEmailVerification();
              },
              child: const Text("Resend Verification Email"),
            ),

            const SizedBox(height: 20),

            
            TextButton(
              onPressed: () {
                authProvider.signOut();
              },
              child: const Text(
                "Sign Out",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}