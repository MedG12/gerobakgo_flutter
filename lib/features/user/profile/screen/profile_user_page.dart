// views/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gerobakgo_with_api/core/themes/app_theme.dart';
import 'package:gerobakgo_with_api/core/widgets/textFormField.dart';
import 'package:gerobakgo_with_api/features/user/profile/view_model/profileUser_viewmodel.dart';
import 'package:gerobakgo_with_api/helper/user_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/view_models/auth_viewmodel.dart';

class ProfileUserPage extends StatefulWidget {
  const ProfileUserPage({super.key});

  @override
  State<ProfileUserPage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfileUserPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = Provider.of<AuthViewmodel>(context, listen: false);
      final profileViewModel = Provider.of<ProfileuserViewmodel>(
        context,
        listen: false,
      );
      authViewModel.init();
      final user = authViewModel.currentUser;
      if (user != null) {
        nameController.text = user.name;
        emailController.text = user.email;
        profileViewModel.setOriginalName(user.name);
      }
      print(user!.token);
      nameController.addListener(() {
        profileViewModel.currentName = nameController.text;
      });
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewmodel>(context);
    final user = authViewModel.currentUser;
    final profileViewModel = Provider.of<ProfileuserViewmodel>(context);
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'My Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.red),
                      onPressed: () {
                        authViewModel.logout().then((_) => context.go('/'));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Foto profil
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        profileViewModel.selectedImage != null
                            ? FileImage(profileViewModel.selectedImage!)
                                as ImageProvider
                            : user.photoUrl == null
                            ? null
                            : NetworkImage(
                              "${dotenv.env['STORAGE_URL']}${user.photoUrl}",
                            ),
                    child:
                        (user.photoUrl == null &&
                                profileViewModel.selectedImage == null)
                            ? Text(
                              UserUtils.getInitials(user.name),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                            : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () {
                        profileViewModel.pickImage();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF5D42D1),
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Form
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Form(
                  key: _formKey,
                  child: FocusScope(
                    onFocusChange: (hasFocus) {
                      if (!hasFocus) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      }
                    },
                    child: Column(
                      spacing: 20,
                      children: [
                        TextFormFieldCustom(
                          controller: nameController,
                          labelText: 'Nama',
                          hintText: 'Masukkan nama anda',
                        ),
                        TextFormFieldCustom(
                          enabled: false,
                          controller: emailController,
                          labelText: 'Email',
                          hintText: 'Masukkan email anda',
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Tombol Edit Profile
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    iconColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor:
                        profileViewModel.isNameChanged ||
                                authViewModel.isLoading ||
                                profileViewModel.selectedImage != null
                            ? AppTheme.primaryDark
                            : AppTheme.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed:
                      profileViewModel.isNameChanged ||
                              authViewModel.isLoading ||
                              profileViewModel.selectedImage != null
                          ? () async {
                            if (!_formKey.currentState!.validate()) return;
                            authViewModel.setLoading = true;
                            final response = await authViewModel.updateUser(
                              profileViewModel.currentName,
                              emailController.text,
                              profileViewModel.selectedImage,
                            );

                            if (response) {
                              profileViewModel.setOriginalName(
                                nameController.text,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Profile updated successfully!',
                                  ),
                                  backgroundColor: AppTheme.success,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    authViewModel.errorMessage ??
                                        'Update failed',
                                  ),
                                  backgroundColor: AppTheme.error,
                                ),
                              );
                            }
                            profileViewModel.reset();
                            authViewModel.setLoading = false;
                          }
                          : null,
                  icon:
                      authViewModel.isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Icon(Icons.edit, size: 18),
                  label: Text(
                    authViewModel.isLoading ? 'Memperbarui...' : 'Edit Profile',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
