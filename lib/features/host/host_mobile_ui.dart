import 'package:aiesec_lar_global/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HostMobileUI extends StatelessWidget {
  const HostMobileUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TextButton(
        onPressed: () => context.read<AuthProvider>().signOut(),
        child: Text('Logout'),
      ),
    );
  }
}
