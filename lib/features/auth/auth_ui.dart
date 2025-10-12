import 'package:aiesec_lar_global/core/widgets/responsive.dart';
import 'package:aiesec_lar_global/features/auth/auth_desktop_ui.dart';
import 'package:aiesec_lar_global/features/auth/auth_mobile_ui.dart';
import 'package:flutter/material.dart';

class AuthUI extends StatelessWidget {
  const AuthUI({super.key});

  @override
  Widget build(BuildContext context) {
    return const Responsive(mobile: AuthMobileUI(), desktop: AuthDesktopUI());
  }
}
