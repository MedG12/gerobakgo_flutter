import 'package:flutter/material.dart';
import 'package:gerobakgo_with_api/core/themes/app_theme.dart';

class TextFormFieldCustom extends StatelessWidget {
  final TextEditingController? controller;
  final String labelText;
  final String hintText;
  final int? valueKey;
  final FormFieldValidator<String>? validator;
  final Icon? prefixIcon;
  final bool? obscureText;
  final Widget? suffixIcon;
  final bool enabled;

  const TextFormFieldCustom({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.valueKey,
    this.validator,
    this.prefixIcon,
    this.obscureText,
    this.suffixIcon,
    this.enabled = true,
  });

  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return '$labelText tidak boleh kosong';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelText, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 10),
        TextFormField(
          onChanged: (tex){
            debugPrint("nilainya berubah $tex");
          },
          enabled: enabled,
          obscureText: obscureText ?? false,
          key: valueKey != null ? ValueKey(valueKey) : null,
          controller: controller,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: enabled ? Colors.black : AppTheme.grey,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: AppTheme.grey),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            focusColor: Theme.of(context).colorScheme.primary,
          ),
          validator: (value) {
            final error = _defaultValidator(value);
            if (error != null) return error;

            if (validator != null) {
              return validator!(value);
            }

            return null;
          },
        ),
      ],
    );
  }
}
