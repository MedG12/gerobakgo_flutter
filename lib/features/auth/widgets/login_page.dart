// views/login_page.dart
import 'package:flutter/material.dart';
import 'package:gerobakgo_with_api/core/themes/app_theme.dart';
import 'package:gerobakgo_with_api/core/widgets/textFormField.dart';
import 'package:gerobakgo_with_api/features/user/profile/screen/profile_user_page.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/view_models/auth_viewmodel.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewmodel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.08),

                // Title
                Text(
                  'Sign In',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 60),

                // Email Field
                TextFormFieldCustom(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'Masukkan email Anda',
                  valueKey: 1,
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
                    color: Colors.grey[600],
                    size: 20,
                  ),
                ),

                const SizedBox(height: 24),

                // Password Field
                TextFormFieldCustom(
                  controller: _passwordController,
                  labelText: 'Password',
                  hintText: 'Masukkan password Anda',
                  valueKey: 2,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppTheme.grey,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                ),
                const SizedBox(height: 12),

                // Forgot Password
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: AppTheme.primaryDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed:
                      authViewModel.isLoading
                          ? null
                          : () async {
                            if (_formKey.currentState!.validate()) {
                              final response = await authViewModel.login(
                                _emailController.text,
                                _passwordController.text,
                              );
                              if (response) {
                                if (authViewModel.currentUser!.role ==
                                    'merchant') {
                                  context.go('/dashboard');
                                } else {
                                  context.go('/home');
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      authViewModel.errorMessage ??
                                          'Login failed',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        authViewModel.isLoading
                            ? Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.5)
                            : Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child:
                  // _isLoading
                  //     ? const SizedBox(
                  //       height: 20,
                  //       width: 20,
                  //       child: CircularProgressIndicator(
                  //         strokeWidth: 2,
                  //         valueColor: AlwaysStoppedAnimation<Color>(
                  //           Colors.white,
                  //         ),
                  //       ),
                  //     )
                  //     :
                  const Text(
                    'Sign In',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),

                const SizedBox(height: 32),

                // Divider with "or"
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: AppTheme.grey.withValues(alpha: 0.5),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("or", style: AppTheme.textTheme.bodySmall),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppTheme.grey.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Google Sign In Button
                OutlinedButton.icon(
                  onPressed: () => {},
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    side: BorderSide(color: AppTheme.grey),
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon:
                  // _isGoogleLoading
                  //     ? const SizedBox(
                  //       width: 20,
                  //       height: 20,
                  //       child: CircularProgressIndicator(strokeWidth: 2),
                  //     )
                  //     :
                  Image.asset(
                    'assets/images/google_icon.png',
                    height: 20,
                    width: 20,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.g_mobiledata,
                          size: 16,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                  label: Text(
                    'Sign In with Google',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't have a account? ",
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: AppTheme.grey),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.go('/register');
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
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
      ),
    );
  }
}
