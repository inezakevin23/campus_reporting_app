import 'package:campus_reporting_app/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _isChecking = false;
  bool _isResending = false;

  // CHECK EMAIL VERIFICATION
  Future<void> _checkVerification() async {
    setState(() {
      _isChecking = true;
    });

    try {
      final isVerified = await ref
          .read(authServiceProvider)
          .checkEmailVerification();

      if (!mounted) return;

      if (isVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email verified successfully!')),
        );

        // The router will identify the user's role
        // and redirect to the correct dashboard.
        context.go('/verify-email');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Your email is not verified yet. '
              'Please check your inbox.',
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to verify email: ${error.message}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  // -----------------------------------------------
  // RESEND VERIFICATION EMAIL
  // -----------------------------------------------

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isResending = true;
    });

    try {
      await ref.read(authServiceProvider).sendVerificationEmail();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Verification email sent again. '
            'Please check your inbox.',
          ),
        ),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.code == 'too-many-requests'
                ? 'Too many requests. Please try again later.'
                : 'Unable to send verification email.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  // -----------------------------------------------
  // SIGN OUT
  // -----------------------------------------------

  Future<void> _signOut() async {
    await ref.read(authServiceProvider).signOut();
  }

  // -----------------------------------------------
  // BUILD
  // -----------------------------------------------

  @override
  Widget build(BuildContext context) {
    final email =
        FirebaseAuth.instance.currentUser?.email ?? 'your ALU email address';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),

        actions: [
          IconButton(
            onPressed: _signOut,
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              const Icon(
                Icons.mark_email_unread_outlined,
                size: 85,
                color: AppTheme.yellow,
              ),

              const SizedBox(height: 24),

              const Text(
                'Verify your ALU email',

                textAlign: TextAlign.center,

                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              const Text(
                'We have sent a verification link to:',

                textAlign: TextAlign.center,

                style: TextStyle(color: Colors.white70),
              ),

              const SizedBox(height: 10),

              Text(
                email,

                textAlign: TextAlign.center,

                style: const TextStyle(
                  color: AppTheme.yellow,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Open your email and click the verification '
                'link sent by Firebase. Once verified, return '
                'to CampusAlert and check your verification status.',

                textAlign: TextAlign.center,

                style: TextStyle(color: Colors.white70, height: 1.6),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,

                child: FilledButton.icon(
                  onPressed: _isChecking ? null : _checkVerification,

                  icon: _isChecking
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.navy,
                          ),
                        )
                      : const Icon(Icons.verified_outlined),

                  label: Text(
                    _isChecking ? 'Checking...' : 'I Have Verified My Email',
                  ),
                ),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: _isResending ? null : _resendVerificationEmail,

                icon: const Icon(Icons.refresh),

                label: Text(
                  _isResending ? 'Sending...' : 'Resend Verification Email',
                ),

                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Check your spam or junk folder if you cannot '
                'find the verification email.',

                textAlign: TextAlign.center,

                style: TextStyle(fontSize: 12, color: Colors.white54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
