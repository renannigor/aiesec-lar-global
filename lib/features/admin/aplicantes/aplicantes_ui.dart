import 'package:aiesec_lar_global/data/services/comite_local_service.dart';
import 'package:aiesec_lar_global/data/services/intercambista_service.dart';
import 'package:aiesec_lar_global/data/services/pdf_termo_service.dart';
import 'package:aiesec_lar_global/features/admin/aplicantes/components/detalhes_host_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

// Imports Core
import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/core/utils/snackbar.dart';

// Imports Data
import 'package:aiesec_lar_global/data/models/intercambista/intercambista.dart';
import 'package:aiesec_lar_global/data/models/aplicacao.dart';
import 'package:aiesec_lar_global/data/models/usuario/usuario.dart';
import 'package:aiesec_lar_global/data/services/aplicacao_service.dart';
import 'package:aiesec_lar_global/data/services/usuario_service.dart';
import 'package:aiesec_lar_global/data/services/collection_references.dart';

// Import do Dialog de Rejeição
import 'package:aiesec_lar_global/features/admin/aplicantes/components/dialog_rejeicao_app.dart';

class AplicantesUI extends StatelessWidget {
  final Intercambista intercambista;

  const AplicantesUI({super.key, required this.intercambista});

  final Color _headerBackground = Colors.white;
  final Color _borderColor = const Color(0xFFEAEAEA);
  final TextStyle _headerTextStyle = const TextStyle(
    color: Color(0xFF6B7280),
    fontWeight: FontWeight.w600,
    fontSize: 12,
  );
  final TextStyle _cellTextStyle = const TextStyle(
    color: Color(0xFF111827),
    fontSize: 13,
  );

  Future<void> _abrirWhatsApp(String telefone) async {
    final numeroLimpo = telefone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/55$numeroLimpo');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      SnackbarUtils.showError("Não foi possível abrir o WhatsApp.");
    }
  }

  // --- LÓGICA DE GERAÇÃO DE PDF (ATUALIZADA) ---
  Future<void> _gerarPdfTermo(BuildContext context, Aplicacao app) async {
    try {
      // 1. Mostra carregamento
      SnackbarUtils.showInfo("Buscando dados para gerar o PDF...");

      // 2. Busca o Host no Firebase
      final host = await UsuarioService.instance.getUsuario(uid: app.hostUid);
      if (host == null) {
        SnackbarUtils.showError("Erro: Host não encontrado no banco de dados.");
        return;
      }

      // 3. Busca o Comitê Local usando o nome do comitê que está na Aplicação
      final comite = await ComiteLocalService.instance.getComitePorNomePodio(
        app.comiteLocal,
      );
      if (comite == null) {
        SnackbarUtils.showError(
          "Erro: Dados do Comitê (${app.comiteLocal}) não encontrados.",
        );
        return;
      }

      // 4. Chama o Service do PDF
      await PdfTermoService.gerarEImprimirTermo(
        host: host,
        ep: intercambista,
        comite: comite,
      );
    } catch (e) {
      debugPrint("Erro ao gerar PDF: $e");
      SnackbarUtils.showError("Erro ao gerar o termo: $e");
    }
  }

  // --- LÓGICA DO DIÁLOGO DE REJEIÇÃO ---
  Future<void> _processarMudancaStatus(
    BuildContext context,
    Aplicacao app,
    StatusAplicacao novoStatus,
  ) async {
    if (novoStatus == StatusAplicacao.rejeitada) {
      final motivoRejeicao = await showDialog<String>(
        context: context,
        builder: (context) => const DialogRejeicaoApp(),
      );

      if (motivoRejeicao != null && motivoRejeicao.isNotEmpty) {
        await AplicacaoService.instance.atualizarRetornoAplicacao(
          aplicacaoId: app.aplicacaoId,
          novoStatus: novoStatus,
          motivo: motivoRejeicao,
        );
        SnackbarUtils.showSuccess("Candidatura rejeitada com sucesso.");
      }
    } else {
      await AplicacaoService.instance.atualizarStatusAplicacao(
        aplicacaoId: app.aplicacaoId,
        novoStatus: novoStatus,
      );

      if (novoStatus == StatusAplicacao.hospedando) {
        await IntercambistaService.instance.atualizarNecessidadeHospedagem(
          intercambistaId: app.intercambistaId,
          precisaHospedagem: false,
        );
      }

      SnackbarUtils.showSuccess("Status atualizado!");
    }
  }

  void _verDetalhesHost(BuildContext context, Usuario host) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: DetalhesHostSheet(host: host),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Controle de Hosts",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Intercambista: ${intercambista.nome}",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: _borderColor, height: 1.0),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseCollections.aplicacoes
            .where('intercambistaId', isEqualTo: intercambista.epId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.maps_home_work_outlined,
                    size: 48,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Nenhum host se candidatou para este EP ainda.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final aplicacoes = snapshot.data!.docs.map((doc) {
            final data = doc.data();
            if (data is Aplicacao) return data;
            return Aplicacao.fromJson(data as Map<String, dynamic>, id: doc.id);
          }).toList();

          aplicacoes.sort((a, b) => b.dataAplicacao.compareTo(a.dataAplicacao));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _borderColor),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Hosts Interessados",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${aplicacoes.length} Total",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1D4ED8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: _borderColor),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: MediaQuery.of(context).size.width - 64,
                      ),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          _headerBackground,
                        ),
                        dataRowMinHeight: 70,
                        dataRowMaxHeight: 70,
                        headingTextStyle: _headerTextStyle,
                        dividerThickness: 1,
                        columnSpacing: 24,
                        columns: const [
                          DataColumn(label: Text('DADOS DO HOST')),
                          DataColumn(label: Text('CONTATO')),
                          DataColumn(label: Text('MENSAGEM / MOTIVO')),
                          DataColumn(label: Text('STATUS DA APLICAÇÃO')),
                          DataColumn(label: Text('DATA')),
                          DataColumn(label: Text('TERMO')),
                          DataColumn(label: Text('AÇÕES')),
                        ],
                        rows: aplicacoes.map((app) {
                          return DataRow(
                            cells: [
                              DataCell(
                                FutureBuilder<Usuario?>(
                                  future: UsuarioService.instance.getUsuario(
                                    uid: app.hostUid,
                                  ),
                                  builder: (context, userSnapshot) {
                                    if (userSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Text("...");
                                    }
                                    final host = userSnapshot.data;
                                    if (host == null) return const Text("?");
                                    return Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: AppColors.primary
                                              .withValues(alpha: 0.1),
                                          backgroundImage:
                                              host.fotoPerfilUrl.isNotEmpty
                                              ? NetworkImage(host.fotoPerfilUrl)
                                              : null,
                                          child: host.fotoPerfilUrl.isEmpty
                                              ? Text(
                                                  host.nome[0].toUpperCase(),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.primary,
                                                  ),
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              host.nome,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              "${host.endereco?.cidade ?? 'Cidade não informada'} - ${host.endereco?.estado ?? ''}",
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              DataCell(
                                FutureBuilder<Usuario?>(
                                  future: UsuarioService.instance.getUsuario(
                                    uid: app.hostUid,
                                  ),
                                  builder: (context, userSnapshot) {
                                    if (!userSnapshot.hasData) {
                                      return const SizedBox();
                                    }
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          userSnapshot.data!.telefone ?? '-',
                                          style: _cellTextStyle,
                                        ),
                                        Text(
                                          userSnapshot.data!.email,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: 200,
                                  child: Text(
                                    app.mensagemHost?.isNotEmpty == true
                                        ? app.mensagemHost!
                                        : "Sem mensagem",
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color:
                                          app.status ==
                                              StatusAplicacao.rejeitada
                                          ? Colors.red.shade700
                                          : Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  height: 35,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: _borderColor),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<StatusAplicacao>(
                                      value: app.status,
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 16,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      items: StatusAplicacao.values.map((
                                        StatusAplicacao s,
                                      ) {
                                        return DropdownMenuItem(
                                          value: s,
                                          child: Text(s.descricao),
                                        );
                                      }).toList(),
                                      onChanged: (StatusAplicacao? novoStatus) {
                                        if (novoStatus != null &&
                                            novoStatus != app.status) {
                                          _processarMudancaStatus(
                                            context,
                                            app,
                                            novoStatus,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  DateFormat(
                                    'dd/MM/yy',
                                  ).format(app.dataAplicacao),
                                  style: _cellTextStyle,
                                ),
                              ),
                              DataCell(
                                app.status == StatusAplicacao.assinaturaTermo
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.picture_as_pdf_outlined,
                                          color: Colors.redAccent,
                                        ),
                                        tooltip: 'Gerar Termo de Hospedagem',
                                        onPressed: () =>
                                            _gerarPdfTermo(context, app),
                                        splashRadius: 20,
                                      )
                                    : const Center(
                                        child: Text(
                                          "-",
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                              ),
                              DataCell(
                                FutureBuilder<Usuario?>(
                                  future: UsuarioService.instance.getUsuario(
                                    uid: app.hostUid,
                                  ),
                                  builder: (context, userSnapshot) {
                                    if (!userSnapshot.hasData) {
                                      return const SizedBox();
                                    }
                                    final host = userSnapshot.data!;
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.message_outlined,
                                            size: 20,
                                            color: Colors.green,
                                          ),
                                          onPressed: () => _abrirWhatsApp(
                                            host.telefone ?? '',
                                          ),
                                          splashRadius: 20,
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.person_outline,
                                            size: 20,
                                            color: Color(0xFF6B7280),
                                          ),
                                          onPressed: () =>
                                              _verDetalhesHost(context, host),
                                          splashRadius: 20,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
