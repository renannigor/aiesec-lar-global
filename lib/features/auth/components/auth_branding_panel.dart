import 'package:aiesec_lar_global/core/widgets/responsive.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AuthBrandingPanel extends StatelessWidget {
  const AuthBrandingPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.symmetric(
        vertical: Responsive.isMobile(context) ? 64 : 0,
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.isMobile(context) ? 32.0 : 64.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: Responsive.isMobile(context)
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              RichText(
                textAlign: Responsive.isMobile(context)
                    ? TextAlign.center
                    : TextAlign.start,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: Responsive.isMobile(context) ? 40 : 56,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.3,
                  ),
                  children: const [
                    TextSpan(text: 'Bem-vindo ao\n'),
                    TextSpan(
                      text: 'Lar Global',
                      style: TextStyle(
                        backgroundColor: Colors.white,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Conectando jovens internacionais da AIESEC com famílias anfitriãs.',
                textAlign: Responsive.isMobile(context)
                    ? TextAlign.center
                    : TextAlign.start,
                style: TextStyle(
                  fontSize: Responsive.isMobile(context) ? 18 : 20,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
