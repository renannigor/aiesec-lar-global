import 'package:aiesec_lar_global/data/models/nps_host.dart';
import 'package:aiesec_lar_global/data/services/collection_references.dart';
import 'package:aiesec_lar_global/data/services/comite_local_service.dart';
import 'package:aiesec_lar_global/features/host/interesses/components/status_aplicacao_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/data/models/aplicacao.dart';
import 'package:aiesec_lar_global/data/services/aplicacao_service.dart';
import 'package:aiesec_lar_global/data/services/intercambista_service.dart';
import 'package:aiesec_lar_global/core/utils/snackbar.dart';

// --- IMPORTS DOS BOTTOM SHEETS ---
import 'package:aiesec_lar_global/features/host/components/detalhes_intercambista_sheet.dart';
import 'package:aiesec_lar_global/features/host/interesses/components/nps_form_sheet.dart';

// IMPORTAR A SUA CLASSE RESPONSIVE
import 'package:aiesec_lar_global/core/widgets/responsive.dart';
import 'package:url_launcher/url_launcher.dart';

class AplicacaoCard extends StatefulWidget {
  final Aplicacao aplicacao;

  const AplicacaoCard({super.key, required this.aplicacao});

  @override
  State<AplicacaoCard> createState() => _AplicacaoCardState();
}

class _AplicacaoCardState extends State<AplicacaoCard> {
  String _formatarData(String? dataIso) {
    if (dataIso == null || dataIso.isEmpty || dataIso == 'Não informado') {
      return 'A definir';
    }
    try {
      final date = DateTime.parse(dataIso);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dataIso.split(' ')[0];
    }
  }

  // --- FUNÇÃO PARA ABRIR O WHATSAPP ---
  Future<void> _abrirWhatsAppComite(BuildContext context) async {
    try {
      SnackbarUtils.showInfo("Buscando contato do comitê...");

      final comite = await ComiteLocalService.instance.getComitePorNomePodio(
        widget.aplicacao.comiteLocal,
      );

      if (comite == null ||
          comite.telefone == null ||
          comite.telefone!.isEmpty) {
        SnackbarUtils.showError(
          "O comitê não possui um número de telefone cadastrado.",
        );
        return;
      }

      final numeroLimpo = comite.telefone!.replaceAll(RegExp(r'[^0-9]'), '');

      final numeroComCodigo = numeroLimpo.startsWith('55')
          ? numeroLimpo
          : '55$numeroLimpo';

      final uri = Uri.parse('https://wa.me/$numeroComCodigo');

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        SnackbarUtils.showError("Não foi possível abrir o WhatsApp.");
      }
    } catch (e) {
      SnackbarUtils.showError("Erro ao buscar contato: $e");
    }
  }

  // --- FUNÇÃO PARA ABRIR O NPS ---
  Future<void> _abrirFormularioNps(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 40,
          ),
          child: NpsFormSheet(aplicacao: widget.aplicacao),
        );
      },
    );
    // Ao fechar o bottom sheet, recarrega o estado para travar o botão se ele enviou
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final chegada = _formatarData(widget.aplicacao.dataChegada);
    final partida = _formatarData(widget.aplicacao.dataPartida);
    final isMobile = Responsive.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- TOPO: Avatar, Nome e Total de Interessados ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                widget.aplicacao.epNome.isNotEmpty
                    ? widget.aplicacao.epNome[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Nome
            Expanded(
              child: Text(
                widget.aplicacao.epNome,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Contagem de Interessados
            FutureBuilder<int>(
              future: AplicacaoService.instance.getQuantidadeAplicacoesAtivas(
                widget.aplicacao.intercambistaId,
              ),
              builder: (context, snapshot) {
                final int qtd = snapshot.data ?? 0;
                return Row(
                  children: [
                    const Icon(Icons.people_alt, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      "$qtd interessados",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),

        // --- MEIO: País e Datas ---
        Wrap(
          spacing: 24,
          runSpacing: 8,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.flag_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  widget.aplicacao.epPais,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.flight_land_outlined,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  "Chegada: $chegada",
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.flight_takeoff_outlined,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  "Partida: $partida",
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),

        // --- RODAPÉ: Botões de Ação ---
        if (isMobile)
          SizedBox(width: double.infinity, child: _buildActionButtons(context))
        else
          Align(
            alignment: Alignment.centerRight,
            child: _buildActionButtons(context),
          ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    List<Widget> botoes = [];

    // --- BOTÃO DE VER DETALHES ---
    final btnDetalhes = ElevatedButton(
      onPressed: () async {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );

        final ep = await IntercambistaService.instance.getIntercambistaPorId(
          widget.aplicacao.intercambistaId,
        );

        if (context.mounted) Navigator.pop(context);

        if (ep != null && context.mounted) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) {
              return Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 40,
                ),
                child: DetalhesIntercambistaSheet(intercambista: ep),
              );
            },
          );
        } else if (context.mounted) {
          SnackbarUtils.showInfo(
            "Erro ao carregar detalhes. Este intercambista pode não estar mais disponível.",
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 20),
      ),
      child: const Text(
        "Ver Detalhes",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );

    // --- BOTÃO DE VER STATUS ---
    final btnVerStatus = OutlinedButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) {
            return Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 40,
              ),
              child: StatusAplicacaoSheet(aplicacao: widget.aplicacao),
            );
          },
        );
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black87,
        side: BorderSide(color: Colors.grey.shade400),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 20),
      ),
      child: const Text("Ver Status"),
    );

    // --- BOTÃO DE WHATSAPP ---
    final btnWhatsApp = OutlinedButton.icon(
      onPressed: () => _abrirWhatsAppComite(context),
      icon: const Icon(Icons.chat, size: 16),
      label: const Text("WhatsApp"),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.green.shade700,
        side: BorderSide(color: Colors.green.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 20),
      ),
    );

    // --- DISTRIBUIÇÃO DOS BOTÕES CONFORME O STATUS ---
    if (widget.aplicacao.status == StatusAplicacao.cancelada) {
      botoes.addAll([
        OutlinedButton.icon(
          onPressed: () => _retomarInteresse(context),
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text("Retomar Interesse"),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
        ),
        btnDetalhes,
      ]);
    } else if (widget.aplicacao.status == StatusAplicacao.rejeitada) {
      botoes.addAll([btnVerStatus, btnDetalhes]);
    } else if (widget.aplicacao.status == StatusAplicacao.concluida) {
      botoes.addAll([
        // NOVO: BOTÃO DE AVALIAÇÃO NPS COM BLOQUEIO DE DUPLICIDADE
        // NOVO: BOTÃO DE AVALIAÇÃO NPS COM BLOQUEIO DE DUPLICIDADE (Usando Collection Reference)
        FutureBuilder<QuerySnapshot<NpsHost>>(
          // <-- Adicionado o tipo <NpsHost>
          future: FirebaseCollections
              .avaliacoesNps // <-- Usando sua classe centralizada
              .where('hostUid', isEqualTo: widget.aplicacao.hostUid)
              .where('nomeIntercambista', isEqualTo: widget.aplicacao.epNome)
              .limit(1)
              .get(),
          builder: (context, snapshot) {
            final jaAvaliou =
                snapshot.hasData && snapshot.data!.docs.isNotEmpty;

            return ElevatedButton.icon(
              onPressed: jaAvaliou ? null : () => _abrirFormularioNps(context),
              icon: Icon(
                jaAvaliou ? Icons.check_circle : Icons.star_rate_rounded,
                size: 18,
              ),
              label: Text(
                jaAvaliou ? "Avaliação Enviada" : "Avaliar Experiência",
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade600,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade200,
                disabledForegroundColor: Colors.grey.shade500,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
            );
          },
        ),
        OutlinedButton.icon(
          onPressed: () {
            SnackbarUtils.showInfo("Gerando certificado... aguarde.");
          },
          icon: const Icon(Icons.workspace_premium, size: 18),
          label: const Text("Certificado"),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.blue.shade700,
            side: BorderSide(color: Colors.blue.shade300),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
        ),
        btnWhatsApp,
        btnDetalhes,
      ]);
    } else {
      botoes.addAll([
        TextButton(
          onPressed: () => _confirmarCancelamento(context),
          style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
          child: const Text("Remover Interesse"),
        ),
        btnWhatsApp,
        btnVerStatus,
        btnDetalhes,
      ]);
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: botoes,
    );
  }

  void _retomarInteresse(BuildContext context) async {
    await AplicacaoService.instance.atualizarStatusAplicacao(
      aplicacaoId: widget.aplicacao.aplicacaoId,
      novoStatus: StatusAplicacao.pendente,
    );
    if (context.mounted) {
      SnackbarUtils.showSuccess(
        "Interesse retomado! A aplicação voltou para Ativos.",
      );
    }
  }

  void _confirmarCancelamento(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Remover interesse?"),
        content: Text(
          "Tem certeza que deseja desistir de hospedar ${widget.aplicacao.epNome}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Voltar", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AplicacaoService.instance.atualizarStatusAplicacao(
                aplicacaoId: widget.aplicacao.aplicacaoId,
                novoStatus: StatusAplicacao.cancelada,
              );
              if (context.mounted) {
                SnackbarUtils.showInfo(
                  "Interesse movido para aba de Cancelados.",
                );
              }
            },
            child: const Text(
              "Sim, remover",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
