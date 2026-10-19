import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const CustomBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.acentoBronce,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed ?? () => Navigator.of(context).maybePop(),
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 64,
          height: 64,
          child: Icon(
            Icons.arrow_back,
            color: AppColors.fondoAzulNoche,
            size: 28,
          ),
        ),
      ),
    );
  }
}
