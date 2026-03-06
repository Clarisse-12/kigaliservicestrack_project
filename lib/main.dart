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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ListingProvider()),
      ],
      child: MaterialApp(
        title: 'Kigali Services & Places Directory',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1F3A93),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        debugShowCheckedModeBanner: false,
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
          } else if (settings.name == '/edit-listing') {
            final listingId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => EditListingScreen(listingId: listingId),
            );
          }
          return null;
        },
      ),
    );
  }
}

class _RootScreen extends StatelessWidget {
  const _RootScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Not logged in
        if (authProvider.currentUser == null) {
          return const LoginScreen();
        }

        // Logged in but email not verified
        if (!authProvider.isEmailVerified) {
          return _buildEmailVerificationScreen(context, authProvider);
        }

        // Logged in and email verified
        return const HomeScreen();
      },
    );
  }

  Widget _buildEmailVerificationScreen(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1F3A93).withOpacity(0.1),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.email_outlined,
                      size: 50,
                      color: Color(0xFF1F3A93),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Verify Your Email',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F3A93),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'A verification email has been sent to ${authProvider.currentUser?.email}. Please check your email and click the verification link.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      authProvider.checkEmailVerificationStatus();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F3A93),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'I Have Verified My Email',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () {
                      authProvider.resendEmailVerification();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Verification email resent. Please check your inbox.',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(
                        color: Color(0xFF1F3A93),
                        width: 2,
                      ),
                    ),
                    child: const Text(
                      'Resend Verification Email',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F3A93),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                TextButton(
                  onPressed: () {
                    authProvider.signOut();
                  },
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
