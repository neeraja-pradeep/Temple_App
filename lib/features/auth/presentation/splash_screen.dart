import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:temple_app/core/services/auth_state_checker.dart';

/// Splash screen that checks authentication state and routes accordingly
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthenticationAndNavigate();
  }

  Future<void> _checkAuthenticationAndNavigate() async {
    try {
      print('🚀 App starting - checking authentication state...');

      // Show loading for a minimum time (better UX)
      await Future.wait([
        _performAuthCheck(),
        Future.delayed(const Duration(seconds: 2)), // Minimum splash time
      ]);

      if (mounted) {
        _navigateBasedOnAuthState();
      }
    } catch (e) {
      print('❌ Error during app startup: $e');
      if (mounted) {
        _navigateToLogin();
      }
    }
  }

  Future<AuthState> _performAuthCheck() async {
    try {
      // Get detailed auth status for logging
      final authStatus = AuthStateChecker.getDetailedAuthStatus();
      print('📊 Authentication Status:');
      print('   Has stored token: ${authStatus['hasStoredToken']}');
      print('   Is token expired: ${authStatus['isTokenExpired']}');
      print('   Token expiry: ${authStatus['tokenExpiry']}');
      print('   User ID: ${authStatus['userId']}');
      print('   Phone: ${authStatus['phoneNumber']}');
      print('   Role: ${authStatus['userRole']}');
      print('   Has Firebase user: ${authStatus['hasFirebaseUser']}');
      print('   Firebase signed in: ${authStatus['isFirebaseSignedIn']}');

      // Check authentication state
      final authState = await AuthStateChecker.checkAuthenticationState();
      print('🎯 Authentication result: ${authState.description}');

      return authState;
    } catch (e) {
      print('❌ Error checking authentication: $e');
      return AuthState.notAuthenticated;
    }
  }

  void _navigateBasedOnAuthState() {
    // This will be called after auth check completes
    // The actual navigation logic will be handled by the parent widget
    // based on the auth state provider
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8C001A), // Deep red
              Color(0xFFB71C1C), // Darker red
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo/Icon
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.temple_buddhist,
                  size: 60.w,
                  color: const Color(0xFF8C001A),
                ),
              ),

              SizedBox(height: 30.h),

              // App Name
              Text(
                'Temple App',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),

              SizedBox(height: 10.h),

              // Subtitle
              Text(
                'Your Spiritual Journey',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white70,
                  letterSpacing: 0.5,
                ),
              ),

              SizedBox(height: 50.h),

              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),

              SizedBox(height: 20.h),

              // Loading text
              Text(
                'Checking authentication...',
                style: TextStyle(fontSize: 14.sp, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
