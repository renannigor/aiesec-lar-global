import 'package:aiesec_lar_global/core/widgets/responsive.dart';
import 'package:aiesec_lar_global/features/admin/admin_desktop_ui.dart';
import 'package:aiesec_lar_global/features/admin/admin_mobile_ui.dart';
import 'package:flutter/material.dart';

class AdminUI extends StatelessWidget {
  const AdminUI({super.key});

  @override
  Widget build(BuildContext context) {
    return const Responsive(mobile: AdminMobileUI(), desktop: AdminDesktopUI());
  }
}
