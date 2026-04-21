import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class NotificacaoService {
  // Transforma "AIESEC em Florianópolis" em "aiesec_em_florianopolis" para criar o tópico do Firebase
  static String formatarTopico(String nomeComite) {
    return nomeComite
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[áàâã]'), 'a')
        .replaceAll(RegExp(r'[éèê]'), 'e')
        .replaceAll(RegExp(r'[íï]'), 'i')
        .replaceAll(RegExp(r'[óôõ]'), 'o')
        .replaceAll(RegExp(r'[úü]'), 'u');
  }

  static Future<void> avisarNovoEP({
    required String comite,
    required String nomeEp,
    required String pais,
  }) async {
    const webhookUrl =
        'https://hook.us2.make.com/y2e9iqxvv9aqnarlo90f8s6jk1hrjhbj';

    try {
      await http.post(
        Uri.parse(webhookUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'comite': formatarTopico(comite),
          'nome_ep': nomeEp,
          'pais': pais,
        }),
      );
      debugPrint(
        '✅ Sinal de notificação enviado ao Make.com para o comitê $comite!',
      );
    } catch (e) {
      debugPrint('❌ Erro ao enviar sinal de notificação para o Make.com: $e');
    }
  }

  // --- NOVOS MÉTODOS PARA O RECEPTOR (HOST) ---

  static Future<void> inicializarEInscrever(String comite) async {
    if (comite.isEmpty) return;

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // 1. Pede permissão para exibir a notificação na tela
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Permissão de notificação concedida!');

      // 2. Inscreve o celular no tópico do comitê dele
      String topico = formatarTopico(comite);
      await messaging.subscribeToTopic(topico);
      debugPrint('🔔 Celular inscrito no tópico: $topico');
    } else {
      debugPrint('Permissão de notificação negada pelo usuário.');
    }
  }

  // Método bônus: Caso o usuário mude de comitê no Perfil, ele sai do antigo e entra no novo
  static Future<void> atualizarTopico(
    String comiteAntigo,
    String comiteNovo,
  ) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    if (comiteAntigo.isNotEmpty) {
      await messaging.unsubscribeFromTopic(formatarTopico(comiteAntigo));
    }
    if (comiteNovo.isNotEmpty) {
      await messaging.subscribeToTopic(formatarTopico(comiteNovo));
    }
  }
}
