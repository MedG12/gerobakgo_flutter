import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gerobakgo_with_api/core/themes/app_theme.dart';
import 'package:gerobakgo_with_api/core/view_models/auth_viewmodel.dart';
import 'package:gerobakgo_with_api/data/models/menu_model.dart';
import 'package:gerobakgo_with_api/features/merchant/dashboard/view_model/dashboard_viewmodel.dart';
import 'package:provider/provider.dart';

class AddEditMenuForm extends StatefulWidget {
  final Menu? menu;

  const AddEditMenuForm({super.key, this.menu});

  @override
  State<AddEditMenuForm> createState() => _AddEditMenuFormState();
}

class _AddEditMenuFormState extends State<AddEditMenuForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  bool _isLoading = false;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.menu != null) {
      _existingImageUrl = widget.menu!.photoUrl;
      _nameController.text = widget.menu!.name;
      _descriptionController.text = widget.menu!.description;
      _priceController.text = widget.menu!.price;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // Fixed: For picking image
  void _pickImage() async {
    try {
      await Provider.of<DashboardViewmodel>(context, listen: false).pickImage();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: ${e.toString()}')),
        );
      }
    }
  }

  // Fixed: Update your submit form method
  Future<void> _submitForm() async {
    // First validate image
    final dashboardViewmodel = Provider.of<DashboardViewmodel>(
      context,
      listen: false,
    );

    if (dashboardViewmodel.selectedImage == null && _existingImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih gambar menu')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        bool success = false;

        if (widget.menu == null) {
          // Adding new menu
          success = await dashboardViewmodel.addMenu(
            _nameController.text,
            _descriptionController.text,
            _priceController.text,
          );

          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Menu berhasil ditambahkan!')),
            );
          }
        } else {
          // Updating existing menu
          success = await dashboardViewmodel.updateMenu(
            widget.menu!.copyWith(
              name: _nameController.text,
              price: _priceController.text,
              description: _descriptionController.text,
            ),
          );

          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Menu berhasil diperbarui!')),
            );
          }
        }

        if (success && mounted) {
          Navigator.of(context).pop();
        } else if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Gagal menyimpan menu')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan menu: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardViewmodel = Provider.of<DashboardViewmodel>(
      context,
      listen: true,
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                widget.menu == null ? 'Tambah Menu Baru' : 'Edit Menu',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child:
                        dashboardViewmodel.selectedImage != null
                            ? Image.file(
                              dashboardViewmodel.selectedImage!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            )
                            : (_existingImageUrl != null
                                ? Image.network(
                                  dotenv.env['STORAGE_URL']! +
                                      _existingImageUrl!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder:
                                      (context, error, stackTrace) => Icon(
                                        Icons.broken_image,
                                        size: 50,
                                        color: Colors.grey[600],
                                      ),
                                )
                                : Icon(
                                  Icons.camera_alt,
                                  size: 50,
                                  color: Colors.grey[600],
                                )),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Fixed: TextButton with proper onPressed
              TextButton(
                onPressed: _pickImage, // Fixed: Added proper onPressed
                child: const Text('Pilih Gambar Menu'),
              ),
              const SizedBox(height: 16),

              // Name field
              TextFormField(
                controller: _nameController,
                style: AppTheme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  labelText: 'Nama Menu',

                  labelStyle: AppTheme.textTheme.bodyMedium!.copyWith(
                    color: AppTheme.grey,
                  ),
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.primaryDark),
                  ),
                  floatingLabelStyle: AppTheme.textTheme.bodyMedium!.copyWith(
                    color: AppTheme.primaryDark,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama menu tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description field
              TextFormField(
                controller: _descriptionController,
                style: AppTheme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  labelStyle: AppTheme.textTheme.bodyMedium!.copyWith(
                    color: AppTheme.grey,
                  ),
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.primaryDark),
                  ),
                  floatingLabelStyle: AppTheme.textTheme.bodyMedium!.copyWith(
                    color: AppTheme.primaryDark,
                  ),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Price field
              TextFormField(
                controller: _priceController,
                style: AppTheme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  labelText: 'Harga',
                  labelStyle: AppTheme.textTheme.bodyMedium!.copyWith(
                    color: AppTheme.grey,
                  ),
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.primaryDark),
                  ),
                  floatingLabelStyle: AppTheme.textTheme.bodyMedium!.copyWith(
                    color: AppTheme.primaryDark,
                  ),
                  prefixText: 'Rp ',
                  prefixStyle: AppTheme.textTheme.bodyMedium!.copyWith(
                    color: AppTheme.grey,
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga tidak boleh kosong';
                  }
                  if (num.tryParse(value) == null || num.parse(value) <= 0) {
                    return 'Masukkan harga yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Fixed: Submit button
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: Text(_isLoading ? 'Menyimpan...' : 'Simpan'),
                onPressed:
                    _isLoading ? null : _submitForm, // Fixed: proper reference
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
