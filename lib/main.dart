import 'package:aiesec_lar_global/aiesec_lar_global.dart';
import 'package:aiesec_lar_global/data/services/auth_service.dart';
import 'package:aiesec_lar_global/providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  // Garante que o Flutter está inicializado antes de chamar o Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Adicione esta linha:
  await initializeDateFormatting('pt_BR', null);

  // Inicializa o Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        StreamProvider<User?>.value(
          value: AuthService.instance.authStateChanges,
          initialData: null,
        ),
        // Provider para os formulários de autenticação
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
      ],
      child: const AiesecLarGlobal(),
    ),
  );
}
