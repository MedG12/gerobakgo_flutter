import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gerobakgo_with_api/core/themes/app_theme.dart';
import 'package:gerobakgo_with_api/core/widgets/textFormField.dart';
import 'package:gerobakgo_with_api/core/view_models/auth_viewmodel.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  int _selectedIndex = 0;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;

  void _onToggle(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Title
              Text(
                'Sign Up',
                style: AppTheme.textTheme.titleLarge?.copyWith(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Toggle Merchant/User
              Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.primary, width: 3),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _onToggle(0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color:
                                _selectedIndex == 0
                                    ? AppTheme.white
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Merchant',
                            style: AppTheme.textTheme.bodyMedium?.copyWith(
                              color:
                                  _selectedIndex == 0
                                      ? AppTheme.black
                                      : AppTheme.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _onToggle(1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color:
                                _selectedIndex == 1
                                    ? AppTheme.white
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'User',
                            style: AppTheme.textTheme.bodyMedium?.copyWith(
                              color:
                                  _selectedIndex == 1
                                      ? AppTheme.black
                                      : AppTheme.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Name Field
                    TextFormFieldCustom(
                      controller: _nameController,
                      labelText: _selectedIndex == 0 ? 'Nama Merchant' : 'Nama',
                      hintText:
                          _selectedIndex == 0
                              ? 'Masukkan Nama Merchant'
                              : 'Masukkan Nama Lengkap',
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: AppTheme.grey,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Email Field
                    TextFormFieldCustom(
                      controller: _emailController,
                      labelText: 'Email',
                      hintText: 'Masukkan email',
                      validator: (value) {
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value!)) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: AppTheme.grey,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Password Field
                    TextFormFieldCustom(
                      controller: _passwordController,
                      labelText: 'Password',
                      hintText: 'Masukkan password',
                      obscureText: _obscurePassword,
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: AppTheme.grey,
                        size: 20,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppTheme.grey,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      validator: (value) {
                        if (value!.length < 8) {
                          return 'Password minimal 8 karakter';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // Sign Up Button
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final response = await authViewModel.register(
                            _emailController.text.trim(),
                            _passwordController.text.trim(),
                            _nameController.text.trim(),
                            _selectedIndex == 0 ? 'merchant' : 'user',
                          );
                          if (response) {
                            setState(() => _isLoading = true);
                            // Navigate to home or next page
                            context.go('/home');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  authViewModel.errorMessage ??
                                      'Registration failed',
                                ),
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            authViewModel.isLoading
                                ? AppTheme.grey.withValues(alpha: 0.5)
                                : AppTheme.primary,
                        foregroundColor: AppTheme.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child:
                          authViewModel.isLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.white,
                                  ),
                                ),
                              )
                              : Text(
                                'Sign Up',
                                style: AppTheme.textTheme.titleMedium,
                              ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Divider with "or"
              Row(
                children: [
                  Expanded(
                    child: Divider(color: AppTheme.grey.withValues(alpha: 0.5)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("or", style: AppTheme.textTheme.bodySmall),
                  ),
                  Expanded(
                    child: Divider(color: AppTheme.grey.withValues(alpha: 0.5)),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Sign Up with Google Button
              OutlinedButton.icon(
                onPressed: () => {},
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppTheme.white,
                  foregroundColor: AppTheme.black,
                  side: BorderSide(color: AppTheme.grey),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon:
                    _isGoogleLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : Image.asset(
                          'assets/images/google_icon.png',
                          width: 20,
                          height: 20,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: AppTheme.grey,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.g_mobiledata,
                                size: 16,
                                color: AppTheme.white,
                              ),
                            );
                          },
                        ),
                label: Text(
                  _isGoogleLoading ? 'Signing up...' : 'Sign Up with Google',
                  style: AppTheme.textTheme.bodyMedium,
                ),
              ),

              const SizedBox(height: 24),

              // Sign In Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: AppTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.grey,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Text(
                      'Sign In',
                      style: AppTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
