import 'dart:convert';
import 'package:aiesec_lar_global/data/services/collection_references.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/podio_credentials_model.dart';
import '../models/intercambista/intercambista.dart';
import '../models/oportunidade.dart';
import 'intercambista_service.dart';
import 'oportunidade_service.dart';

class PodioService {
  final _credenciaisRef = FirebaseCollections.credenciaisApiPodio;
  final _firestore = FirebaseFirestore.instance;

  /// Verifica o tempo desde a última sincronização antes de chamar a API
  Future<void> sincronizarComCooldown() async {
    final docRef = _firestore.collection('configuracoes').doc('sync_podio');

    try {
      final snapshot = await docRef.get();
      const tempoDeEspera = Duration(hours: 2); // Pode ajustar o tempo aqui

      if (snapshot.exists) {
        final dataUltimaSync =
            (snapshot.data()?['ultima_sincronizacao'] as Timestamp?)?.toDate();

        if (dataUltimaSync != null) {
          final diferenca = DateTime.now().difference(dataUltimaSync);

          if (diferenca < tempoDeEspera) {
            debugPrint(
              "Sincronização ignorada. Última sync foi há ${diferenca.inMinutes} minutos. Lendo do cache do Firebase.",
            );
            return;
          }
        }
      }

      debugPrint("Iniciando sincronização com o Podio...");
      await sincronizarTudo();

      // Atualiza o relógio no Firestore
      await docRef.set({
        'ultima_sincronizacao': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Erro no controle de sincronização: $e");
    }
  }

  /// Função principal que orquestra toda a sincronização entre Podio e Firebase
  Future<void> sincronizarTudo() async {
    try {
      debugPrint("1. Buscando credenciais no banco de dados...");

      // 1. Puxa TODOS os documentos usando a nova referência tipada
      final snapshot = await _credenciaisRef.get();

      if (snapshot.docs.isEmpty) {
        throw Exception("Nenhuma credencial encontrada no Firestore.");
      }

      PodioCredentialsModel? credenciaisEps;
      PodioCredentialsModel? credenciaisOps;

      // 2. Separa as credenciais
      for (var doc in snapshot.docs) {
        final cred = doc.data();

        if (cred.appType == PodioAppType.epsIcx) {
          credenciaisEps = cred;
        } else if (cred.appType == PodioAppType.opensIcx) {
          credenciaisOps = cred;
        }
      }

      if (credenciaisEps == null || credenciaisOps == null) {
        throw Exception(
          "Faltam credenciais. Certifique-se de ter um documento com app='EPs ICX' e outro com app='Opens ICX'.",
        );
      }

      debugPrint("2. Sincronizando Opens ICX (Oportunidades)...");
      final listaOPs = await _buscarESalvarOportunidades(credenciaisOps);

      debugPrint("3. Sincronizando EPs ICX (Intercambistas)...");
      await _buscarESalvarIntercambistas(credenciaisEps, listaOPs);

      debugPrint("Sincronização concluída com sucesso! 🎉");
    } catch (e) {
      debugPrint("Erro durante a sincronização: $e");
      rethrow;
    }
  }

  // ==========================================================
  // LÓGICA DAS OPORTUNIDADES (OPs)
  // ==========================================================
  Future<List<Oportunidade>> _buscarESalvarOportunidades(
    PodioCredentialsModel credenciais,
  ) async {
    final authUrl = Uri.parse("https://api.podio.com/oauth/token/v2");

    debugPrint("Autenticando no Podio para acessar OPs...");

    final authResponse = await http.post(
      authUrl,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        "grant_type": "app",
        "app_id": int.tryParse(credenciais.appId.toString()) ?? 0,
        "app_token": credenciais.appToken,
        "client_id": credenciais.clientId,
        "client_secret": credenciais.clientSecret,
      }),
    );

    if (authResponse.statusCode != 200) {
      throw Exception("Erro Auth OPs: ${authResponse.body}");
    }

    final accessToken = jsonDecode(authResponse.body)['access_token'];

    // Puxando até 500 OPs por vez
    final itemsUrl = Uri.parse(
      "https://api.podio.com/item/app/${credenciais.appId}/?limit=500",
    );
    final itemsResponse = await http.get(
      itemsUrl,
      headers: {"Authorization": "OAuth2 $accessToken"},
    );

    if (itemsResponse.statusCode != 200) {
      throw Exception("Erro ao buscar OPs: ${itemsResponse.body}");
    }

    final dados = jsonDecode(itemsResponse.body);
    List items = dados['items'] ?? [];
    List<Oportunidade> opsList = [];

    for (var item in items) {
      try {
        List fields = item['fields'] ?? [];

        final opData = {
          'OP ID': _extrairValor(fields, "op-id-2", "text"),
          'Empresa/ONG': _extrairValor(fields, "titulo", "text"),
          'Projeto/Vaga': _extrairValor(
            fields,
            "projetovaga-de-trabalho-3",
            "text",
          ),
          'Comitê': _extrairValor(fields, "c", "app"),
          'Área': _extrairValor(fields, "operacao-de-icx", "category"),
          'Duração Total': _extrairValor(
            fields,
            "quantidade-de-semanas",
            "number",
          ),
          'Financiamento GV': _extrairValor(
            fields,
            "se-gv-financiamento",
            "category",
          ),
        };

        final novaOp = Oportunidade.fromPodio(opData);

        // Se o OP ID não existir, ignora este item para não quebrar o banco
        if (novaOp.opId.isEmpty || novaOp.opId == 'Não preenchido') {
          debugPrint("Aviso: Oportunidade ignorada por estar sem OP ID.");
          continue;
        }

        opsList.add(novaOp);

        // Salva no banco de dados (Upsert)
        await OportunidadeService.instance.salvarOportunidade(
          oportunidade: novaOp,
        );
      } catch (e) {
        debugPrint("Erro ao processar uma oportunidade específica: $e");
      }
    }

    return opsList;
  }

  // ==========================================================
  // LÓGICA DOS INTERCAMBISTAS (EPs)
  // ==========================================================
  Future<void> _buscarESalvarIntercambistas(
    PodioCredentialsModel credenciais,
    List<Oportunidade> opsSalvas,
  ) async {
    final authUrl = Uri.parse("https://api.podio.com/oauth/token/v2");

    final authResponse = await http.post(
      authUrl,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        "grant_type": "app",
        "app_id": int.tryParse(credenciais.appId.toString()) ?? 0,
        "app_token": credenciais.appToken,
        "client_id": credenciais.clientId,
        "client_secret": credenciais.clientSecret,
      }),
    );

    if (authResponse.statusCode != 200) {
      throw Exception("Erro Auth EPs: ${authResponse.body}");
    }

    final accessToken = jsonDecode(authResponse.body)['access_token'];

    // Puxando até 500 EPs por vez
    final itemsUrl = Uri.parse(
      "https://api.podio.com/item/app/${credenciais.appId}/?limit=500",
    );
    final itemsResponse = await http.get(
      itemsUrl,
      headers: {"Authorization": "OAuth2 $accessToken"},
    );

    if (itemsResponse.statusCode != 200) {
      throw Exception("Erro ao buscar EPs: ${itemsResponse.body}");
    }

    final dados = jsonDecode(itemsResponse.body);
    List items = dados['items'] ?? [];

    for (var item in items) {
      try {
        List fields = item['fields'] ?? [];

        final epData = {
          'Nome do EP': _extrairValor(fields, "nome-de-ep", "text"),
          'EP ID': _extrairValor(fields, "ep-id-2", "text"),
          'Comitê': _extrairValor(fields, "relacionamento-4", "app"),
          'OP ID': _extrairValor(fields, "open-de-icx", "app"),
          'Área': _extrairValor(fields, "area", "category"),
          'Status': _extrairValor(fields, "status", "category"),
          'Data RE Presencial': _extrairValor(fields, "data-de-re", "date"),
          'Data FIN Presencial': _extrairValor(fields, "data-de-fin", "date"),
          'Entidade Abroad': _extrairValor(fields, "entidade-abroad", "app"),
        };

        // CRUZAMENTO DE DADOS: Regras de Negócio de Hospedagem
        String opIdDoEp = epData['OP ID'] ?? '';
        String statusDoEp = epData['Status'] ?? ''; // Puxa o status do EP
        bool precisaHospedagem = false;

        if (opIdDoEp.isNotEmpty && opIdDoEp != 'Não preenchido') {
          final opMatch = opsSalvas.where((op) => op.opId == opIdDoEp).toList();

          if (opMatch.isNotEmpty) {
            final opDoEp = opMatch.first;

            int semanas = opDoEp.duracaoTotal;

            bool programaCurto = semanas > 0 && semanas <= 12;
            bool ongNaoAcomoda =
                opDoEp.financiamentoGv != 'Pela própria ONG com Lar Global';

            // Nova regra: Valida se o status é Approved ou Realized
            bool statusPermiteHost =
                statusDoEp == 'Approved' || statusDoEp == 'Realized';

            // Só marca como true se cumprir todos os requisitos
            if (programaCurto && ongNaoAcomoda && statusPermiteHost) {
              precisaHospedagem = true;
            }
          }
        }

        final novoEp = Intercambista.fromPodio(
          epData,
          precisaHospedagem: precisaHospedagem,
        );

        if (novoEp.epId.isEmpty || novoEp.epId == 'Não preenchido') {
          debugPrint("Aviso: EP ignorado por estar sem EP ID.");
          continue;
        }

        // Salva no banco de dados
        await IntercambistaService.instance.salvarIntercambista(
          intercambista: novoEp,
        );
      } catch (e) {
        debugPrint("Erro ao processar um intercambista específico: $e");
      }
    }
  }

  // ==========================================================
  // FUNÇÃO AUXILIAR DE LIMPEZA DO JSON DO PODIO
  // ==========================================================
  String _extrairValor(List fields, String externalId, String tipo) {
    for (var field in fields) {
      if (field['external_id'] == externalId) {
        var valores = field['values'];
        if (valores != null && valores.isNotEmpty) {
          var item = valores[0];

          // Tratamento especial para Datas
          if (tipo == 'date') {
            return item['start_date'] ?? item['start'] ?? 'Não informado';
          }

          var valorPrincipal = item['value'];
          if (valorPrincipal == null) return "Não preenchido";

          // Limpa tags de HTML caso o usuário tenha formatado no Podio
          if (tipo == 'text' || tipo == 'calculation') {
            return valorPrincipal.toString().replaceAll(RegExp(r'<[^>]*>'), '');
          }
          // Categorias (Tags)
          else if (tipo == 'category') {
            return valorPrincipal['text']?.toString() ?? 'Não informado';
          }
          // Relacionamento com outros Apps
          else if (tipo == 'app') {
            return valorPrincipal['title']?.toString() ??
                'Referência sem título';
          }
          // Números (O Podio costuma enviar como "12.0000")
          else if (tipo == 'number') {
            return double.tryParse(
                  valorPrincipal.toString(),
                )?.toInt().toString() ??
                '0';
          }
          // Fallback geral
          else {
            return valorPrincipal.toString();
          }
        }
      }
    }
    return "Não preenchido";
  }
}
