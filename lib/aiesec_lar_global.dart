import 'package:aiesec_lar_global/auth_gate.dart';
import 'package:aiesec_lar_global/core/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AiesecLarGlobal extends StatelessWidget {
  const AiesecLarGlobal({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: SnackbarUtils.messengerKey,
      title: 'Lar Global | AIESEC no Brasil',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const AuthGate(),
    );
  }
}
