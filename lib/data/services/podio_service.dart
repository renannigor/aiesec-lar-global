import 'dart:convert';
import 'package:aiesec_lar_global/data/models/nps_host.dart';
import 'package:aiesec_lar_global/data/models/oportunidade.dart';
import 'package:aiesec_lar_global/data/services/collection_references.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/podio_credentials_model.dart';
import '../models/intercambista/intercambista.dart';
import '../models/usuario/usuario.dart';
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
      const tempoDeEspera = Duration(hours: 2);

      if (snapshot.exists) {
        final dataUltimaSync =
            (snapshot.data()?['ultima_sincronizacao'] as Timestamp?)?.toDate();

        if (dataUltimaSync != null) {
          final diferenca = DateTime.now().difference(dataUltimaSync);

          if (diferenca < tempoDeEspera) {
            debugPrint(
              "Sincronização ignorada. Última sync foi há ${diferenca.inMinutes} minutos. Lendo do cache.",
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

  /// Função principal que orquestra toda a sincronização em lote (EPs e OPs)
  Future<void> sincronizarTudo() async {
    try {
      debugPrint("1. Buscando credenciais no banco de dados...");

      final snapshot = await _credenciaisRef.get();

      if (snapshot.docs.isEmpty) {
        throw Exception("Nenhuma credencial encontrada no Firestore.");
      }

      PodioCredentialsModel? credenciaisEps;
      PodioCredentialsModel? credenciaisOps;

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
  // INTEGRAÇÃO DE HOSTS (CONTACTS) - CADASTRAR/ATUALIZAR/DELETAR
  // ==========================================================

  /// Envia ou atualiza os dados do Host no Podio e retorna o novo item_id (se criado)
  Future<String?> syncHostNoPodio(Usuario usuario) async {
    try {
      // 1. Puxa as credenciais específicas do App Contacts
      final snapshot = await _credenciaisRef.get();
      final credDoc = snapshot.docs.firstWhere(
        (doc) => doc.data().appType == PodioAppType.larGlobal,
        orElse: () =>
            throw Exception("Credencial do App Lar Global não encontrada."),
      );
      final credenciais = credDoc.data();

      // 2. Autentica e gera o Token
      final accessToken = await _autenticarApp(credenciais);

      final headers = {
        "Authorization": "OAuth2 $accessToken",
        "Content-Type": "application/json",
      };

      final payloadStr = jsonEncode(usuario.toPodioPayload());

      // 3. Decide se é Criação (POST) ou Atualização (PUT)
      if (usuario.podioItemId != null && usuario.podioItemId!.isNotEmpty) {
        // ATUALIZAÇÃO
        debugPrint("Atualizando Host ${usuario.podioItemId} no Podio...");
        final putUrl = Uri.parse(
          "https://api.podio.com/item/${usuario.podioItemId}",
        );

        final response = await http.put(
          putUrl,
          headers: headers,
          body: payloadStr,
        );
        if (response.statusCode != 200 && response.statusCode != 204) {
          throw Exception("Erro ao atualizar Host: ${response.body}");
        }
        return usuario.podioItemId;
      } else {
        // CRIAÇÃO
        debugPrint("Criando novo Host no Podio...");
        final postUrl = Uri.parse(
          "https://api.podio.com/item/app/${credenciais.appId}/",
        );

        final response = await http.post(
          postUrl,
          headers: headers,
          body: payloadStr,
        );
        if (response.statusCode == 200) {
          final newItemId = jsonDecode(response.body)['item_id'].toString();
          debugPrint("Host criado com ID: $newItemId");
          return newItemId;
        } else {
          throw Exception("Erro ao criar Host: ${response.body}");
        }
      }
    } catch (e) {
      debugPrint("Falha na sincronização do Host com o Podio: $e");
      return null;
    }
  }

  /// Deleta permanentemente o Host no Podio usando o item_id
  Future<bool> deletarHostNoPodio(String podioItemId) async {
    try {
      final snapshot = await _credenciaisRef.get();
      final credDoc = snapshot.docs.firstWhere(
        (doc) => doc.data().appType == PodioAppType.larGlobal,
      );
      final accessToken = await _autenticarApp(credDoc.data());

      final deleteUrl = Uri.parse("https://api.podio.com/item/$podioItemId");
      final response = await http.delete(
        deleteUrl,
        headers: {"Authorization": "OAuth2 $accessToken"},
      );

      if (response.statusCode == 204) {
        debugPrint("Host deletado do Podio com sucesso.");
        return true;
      } else {
        throw Exception("Erro ao deletar: ${response.body}");
      }
    } catch (e) {
      debugPrint("Falha ao deletar Host do Podio: $e");
      return false;
    }
  }

  /// Helper genérico de Autenticação na API para um App específico
  Future<String> _autenticarApp(PodioCredentialsModel credenciais) async {
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
      throw Exception(
        "Erro Auth App ${credenciais.appType?.nomePodio}: ${authResponse.body}",
      );
    }
    return jsonDecode(authResponse.body)['access_token'];
  }

  // ==========================================================
  // LÓGICA DAS OPORTUNIDADES E EPs (MANTIDAS INTACTAS)
  // ==========================================================
  Future<List<Oportunidade>> _buscarESalvarOportunidades(
    PodioCredentialsModel credenciais,
  ) async {
    final accessToken = await _autenticarApp(credenciais);

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

        if (novaOp.opId.isEmpty || novaOp.opId == 'Não preenchido') {
          continue;
        }

        opsList.add(novaOp);
        await OportunidadeService.instance.salvarOportunidade(
          oportunidade: novaOp,
        );
      } catch (e) {
        debugPrint("Erro ao processar uma oportunidade específica: $e");
      }
    }
    return opsList;
  }

  Future<void> _buscarESalvarIntercambistas(
    PodioCredentialsModel credenciais,
    List<Oportunidade> opsSalvas,
  ) async {
    final accessToken = await _autenticarApp(credenciais);

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

        String opIdDoEp = epData['OP ID'] ?? '';
        String statusDoEp = epData['Status'] ?? '';
        bool precisaHospedagem = false;

        if (opIdDoEp.isNotEmpty && opIdDoEp != 'Não preenchido') {
          final opMatch = opsSalvas.where((op) => op.opId == opIdDoEp).toList();

          if (opMatch.isNotEmpty) {
            final opDoEp = opMatch.first;
            int semanas = opDoEp.duracaoTotal;

            bool programaCurto = semanas > 0 && semanas <= 12;
            bool ongNaoAcomoda =
                opDoEp.financiamentoGv != 'Pela própria ONG com Lar Global';
            bool statusPermiteHost =
                statusDoEp == 'Approved' || statusDoEp == 'Realized';

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
          continue;
        }

        await IntercambistaService.instance.salvarIntercambista(
          intercambista: novoEp,
        );
      } catch (e) {
        debugPrint("Erro ao processar um intercambista específico: $e");
      }
    }
  }

  Future<String?> syncNpsNoPodio(NpsHost nps) async {
    try {
      final snapshot = await _credenciaisRef.get();
      final credDoc = snapshot.docs.firstWhere(
        (doc) => doc.data().appType == PodioAppType.nps,
      );

      final accessToken = await _autenticarApp(credDoc.data());
      final postUrl = Uri.parse(
        "https://api.podio.com/item/app/${credDoc.data().appId}/",
      );

      final headers = {
        "Authorization": "OAuth2 $accessToken",
        "Content-Type": "application/json",
      };

      final response = await http.post(
        postUrl,
        headers: headers,
        body: jsonEncode(nps.toPodioPayload()),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['item_id'].toString();
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      debugPrint("Falha na sincronização do NPS: $e");
      return null;
    }
  }

  /// Faz o upload de uma imagem por bytes para o Podio e retorna o ID gerado.
  /// Compatível com Flutter Web e Mobile.
  Future<int?> uploadArquivoNps({
    required List<int> bytes,
    required String fileName,
  }) async {
    try {
      final snapshot = await _credenciaisRef.get();
      final credDoc = snapshot.docs.firstWhere(
        (doc) => doc.data().appType == PodioAppType.nps,
      );

      final accessToken = await _autenticarApp(credDoc.data());

      final uploadUrl = Uri.parse("https://api.podio.com/file/v2/");
      var request = http.MultipartRequest('POST', uploadUrl);

      request.headers.addAll({"Authorization": "OAuth2 $accessToken"});

      // NOVO: Garantia de que o arquivo sempre terá um nome válido (Extensão jpg por padrão)
      final nomeSeguro = (fileName.trim().isEmpty || fileName == 'null')
          ? 'foto_experiencia.jpg'
          : fileName;

      // NOVO: O Podio exige que o "filename" seja enviado como um campo de texto no form!
      request.fields['filename'] = nomeSeguro;

      request.files.add(
        http.MultipartFile.fromBytes('source', bytes, filename: nomeSeguro),
      );

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseData);
        return jsonResponse['file_id'] as int;
      } else {
        debugPrint("Erro no upload da foto para o Podio: $responseData");
        return null;
      }
    } catch (e) {
      debugPrint("Falha na tentativa de enviar a foto para o Podio: $e");
      return null;
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

          if (tipo == 'date') {
            return item['start_date'] ?? item['start'] ?? 'Não informado';
          }

          var valorPrincipal = item['value'];
          if (valorPrincipal == null) return "Não preenchido";

          if (tipo == 'text' || tipo == 'calculation') {
            return valorPrincipal.toString().replaceAll(RegExp(r'<[^>]*>'), '');
          } else if (tipo == 'category') {
            return valorPrincipal['text']?.toString() ?? 'Não informado';
          } else if (tipo == 'app') {
            return valorPrincipal['title']?.toString() ??
                'Referência sem título';
          } else if (tipo == 'number') {
            return double.tryParse(
                  valorPrincipal.toString(),
                )?.toInt().toString() ??
                '0';
          } else {
            return valorPrincipal.toString();
          }
        }
      }
    }
    return "Não preenchido";
  }
}
