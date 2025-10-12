import 'package:aiesec_lar_global/core/widgets/responsive.dart';
import 'package:aiesec_lar_global/features/host/host_desktop_ui.dart';
import 'package:aiesec_lar_global/features/host/host_mobile_ui.dart';
import 'package:flutter/material.dart';

class HostUI extends StatelessWidget {
  const HostUI({super.key});

  @override
  Widget build(BuildContext context) {
    return const Responsive(mobile: HostMobileUI(), desktop: HostDesktopUI());
  }
}
