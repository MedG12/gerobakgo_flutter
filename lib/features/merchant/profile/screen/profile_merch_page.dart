// views/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gerobakgo_with_api/core/themes/app_theme.dart';
import 'package:gerobakgo_with_api/core/widgets/textFormField.dart';
import 'package:gerobakgo_with_api/data/models/merchant_model.dart';
import 'package:gerobakgo_with_api/features/merchant/profile/screen/time_picker_field.dart';
import 'package:gerobakgo_with_api/features/merchant/profile/view_model/profileMerchant_viewmodel.dart';
import 'package:gerobakgo_with_api/helper/time_utils.dart';
import 'package:gerobakgo_with_api/helper/user_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/view_models/auth_viewmodel.dart';

class ProfileMerchPage extends StatefulWidget {
  const ProfileMerchPage({super.key});

  @override
  State<ProfileMerchPage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfileMerchPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = Provider.of<AuthViewmodel>(context, listen: false);
      final profileViewModel = Provider.of<ProfileMerchViewmodel>(
        context,
        listen: false,
      );
      authViewModel.init();
      final user = authViewModel.currentUser;
      final merchant = authViewModel.currentMerchant;
      if (user != null && merchant != null) {
        nameController.text = user.name;
        emailController.text = user.email;
        descriptionController.text = merchant.description ?? '';
        TimeOfDay? openTime;
        TimeOfDay? closeTime;
        if (merchant.closeHour != null && merchant.openHour != null) {
          openTime = TimeUtils.parseTimeString(merchant.openHour);
          closeTime = TimeUtils.parseTimeString(merchant.closeHour);
        }
        profileViewModel.setOriginalValues(
          name: user.name,
          description: merchant.description,
          openHour: openTime,
          closeHour: closeTime,
        );
      }
      nameController.addListener(() {
        profileViewModel.currentName = nameController.text;
      });
      descriptionController.addListener(() {
        profileViewModel.currentDescription = descriptionController.text;
      });
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, bool isOpenTime) async {
    final profileViewModel = Provider.of<ProfileMerchViewmodel>(
      context,
      listen: false,
    );

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime:
          isOpenTime
              ? (profileViewModel.currentOpenHour ?? TimeOfDay.now())
              : (profileViewModel.currentCloseHour ?? TimeOfDay.now()),
      builder: (BuildContext context, Widget? child) {
        return child!;
      },
    );

    if (picked != null) {
      if (isOpenTime) {
        profileViewModel.currentOpenHour = picked;
      } else {
        profileViewModel.currentCloseHour = picked;
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authViewModel = Provider.of<AuthViewmodel>(context, listen: false);
    final profileViewModel = Provider.of<ProfileMerchViewmodel>(
      context,
      listen: false,
    );

    try {
      if (profileViewModel.userHasChanges) {
        final userUpdateSuccess = await authViewModel.updateUser(
          profileViewModel.currentName,
          emailController.text,
          profileViewModel.selectedImage,
        );

        if (!userUpdateSuccess) {
          _showErrorMessage(
            authViewModel.errorMessage ?? 'Failed to update user profile',
          );
          return;
        }
      }
      if (profileViewModel.merchHasChanges) {
        final merchantUpdateSuccess = await authViewModel.updateMerchant(
          profileViewModel.currentDescription!,
          TimeUtils.formatTimeOfDay(profileViewModel.currentOpenHour),
          TimeUtils.formatTimeOfDay(profileViewModel.currentCloseHour),
        );

        if (!merchantUpdateSuccess) {
          _showErrorMessage(
            profileViewModel.errorMessage ??
                'Failed to update merchant profile',
          );
          return;
        }
      }

      profileViewModel.setOriginalValues(
        name: nameController.text,
        description: descriptionController.text,
        openHour: profileViewModel.currentOpenHour,
        closeHour: profileViewModel.currentCloseHour,
      );
      profileViewModel.resetToOriginal();
      _showSuccessMessage('Profile updated successfully!');
    } catch (e) {
      _showErrorMessage('Update failed: $e');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.success),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewmodel>(context);
    final user = authViewModel.currentUser;
    final profileViewModel = Provider.of<ProfileMerchViewmodel>(context);
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Deskripsi",
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              maxLines: 2,
                              controller: descriptionController,
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(color: Colors.black),
                              decoration: InputDecoration(
                                hintText: "Masukkan deskripsi",
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(color: AppTheme.grey),
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                                focusColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Deksripsi tidak boleh kosong';
                                }

                                return null;
                              },
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Jam Operasional',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: timePickerField(
                                    "openHours",
                                    profileViewModel.currentOpenHour,
                                    "Pilih Jam Buka",
                                    () => _selectTime(context, true),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Text('sampai'),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: // Close time field
                                      timePickerField(
                                    "closeHours",
                                    profileViewModel.currentCloseHour,
                                    "Pilih Jam Tutup",
                                    () async =>
                                        await _selectTime(context, false),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
                        profileViewModel.userHasChanges ||
                                authViewModel.isLoading ||
                                profileViewModel.merchHasChanges
                            ? AppTheme.primaryDark
                            : AppTheme.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed:
                      profileViewModel.userHasChanges ||
                              authViewModel.isLoading ||
                              profileViewModel.merchHasChanges
                          ? () async {
                            _updateProfile();
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
