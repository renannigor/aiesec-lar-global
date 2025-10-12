import 'package:aiesec_lar_global/core/widgets/responsive.dart';
import 'package:aiesec_lar_global/features/super_admin/super_admin_desktop_ui.dart';
import 'package:aiesec_lar_global/features/super_admin/super_admin_mobile_ui.dart';
import 'package:flutter/material.dart';

class SuperAdminUI extends StatelessWidget {
  const SuperAdminUI({super.key});

  @override
  Widget build(BuildContext context) {
    return const Responsive(mobile: SuperAdminMobileUI(), desktop: SuperAdminDesktopUI());
  }
}
