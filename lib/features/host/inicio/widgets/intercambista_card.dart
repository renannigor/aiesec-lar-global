import 'package:aiesec_lar_global/data/services/auth_service.dart';
import 'package:aiesec_lar_global/features/host/components/detalhes_intercambista_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// --- IMPORTS PARA O BANCO E ESTADOS ---
import 'package:aiesec_lar_global/data/models/aplicacao.dart';
import 'package:aiesec_lar_global/data/services/aplicacao_service.dart';
import 'package:aiesec_lar_global/core/utils/snackbar.dart';

// NOVO IMPORT: Para buscar o perfil do usuário
import 'package:aiesec_lar_global/data/services/usuario_service.dart';

import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/data/models/intercambista/intercambista.dart';

class IntercambistaCard extends StatefulWidget {
  final Intercambista intercambista;
  final VoidCallback onInteresseSalvo;

  const IntercambistaCard({
    super.key,
    required this.intercambista,
    required this.onInteresseSalvo,
  });

  @override
  State<IntercambistaCard> createState() => _IntercambistaCardState();
}

class _IntercambistaCardState extends State<IntercambistaCard> {
  bool _isProcessing = false;

  String _formatDateString(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == 'Não informado') {
      return 'A definir';
    }
    try {
      final d = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(d);
    } catch (e) {
      return dateStr.split(' ')[0];
    }
  }

  Future<void> _toggleInteresse() async {
    if (_isProcessing) return;

    final authUser = AuthService.instance.currentUser;
    if (authUser == null) {
      SnackbarUtils.showInfo(
        "Você precisa estar logado para demonstrar interesse.",
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // --- 1. VERIFICAÇÃO DE PERFIL 80% ---
      final usuario = await UsuarioService.instance.getUsuario(
        uid: authUser.uid,
      );

      if (usuario != null) {
        final progresso = usuario.progressoPreenchimento;
        if (progresso < 0.80) {
          final atual = (progresso * 100).toInt();
          SnackbarUtils.showError(
            "Seu perfil está $atual% completo. Preencha pelo menos 80% na aba 'Meu Perfil' para demonstrar interesse!",
          );
          setState(() => _isProcessing = false);
          return;
        }
      }

      // --- 2. REGISTRA O INTERESSE NORMALMENTE ---
      final ep = widget.intercambista;
      final hostUid = authUser.uid;

      final aplicacoes = await AplicacaoService.instance.getAplicacaoDoHost(
        hostUid: hostUid,
        intercambistaId: ep.epId,
      );

      if (aplicacoes.isEmpty) {
        final novaAplicacao = Aplicacao(
          aplicacaoId: '${hostUid}_${ep.epId}',
          hostUid: hostUid,
          intercambistaId: ep.epId,
          comiteLocal: ep.comite,
          status: StatusAplicacao.pendente,
          dataAplicacao: DateTime.now(),
          dataUltimaAtualizacao: DateTime.now(),
          epNome: ep.nome,
          epPais: ep.pais ?? ep.entidadeAbroad,
          dataChegada: ep.dataChegada ?? ep.dataRePresencial,
          dataPartida: ep.dataPartida ?? ep.dataFinPresencial,
        );

        await AplicacaoService.instance.criarAplicacao(
          aplicacao: novaAplicacao,
        );

        if (mounted) {
          SnackbarUtils.showSuccess("Interesse manifestado para ${ep.nome}!");
          widget.onInteresseSalvo();
        }
      } else {
        final aplicacaoExistente = aplicacoes.first;

        if (aplicacaoExistente.status == StatusAplicacao.cancelada) {
          await AplicacaoService.instance.atualizarStatusAplicacao(
            aplicacaoId: aplicacaoExistente.aplicacaoId,
            novoStatus: StatusAplicacao.pendente,
          );

          if (mounted) {
            SnackbarUtils.showSuccess("Interesse retomado para ${ep.nome}!");
            widget.onInteresseSalvo();
          }
        } else {
          await AplicacaoService.instance.atualizarStatusAplicacao(
            aplicacaoId: aplicacaoExistente.aplicacaoId,
            novoStatus: StatusAplicacao.cancelada,
          );

          if (mounted) {
            SnackbarUtils.showInfo("Interesse removido para ${ep.nome}.");
          }
        }
      }
    } catch (e) {
      if (mounted) SnackbarUtils.showInfo("Erro ao atualizar interesse.");
      debugPrint("Erro: $e");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _abrirDetalhes() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 40,
          ),
          child: DetalhesIntercambistaSheet(
            intercambista: widget.intercambista,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ep = widget.intercambista;
    final bool precisaHospedagem = ep.precisaHospedagem;

    final Color statusColor = precisaHospedagem
        ? Colors.orange.shade600
        : Colors.green.shade600;
    final Color statusBgColor = precisaHospedagem
        ? Colors.orange.shade50
        : Colors.green.shade50;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- CORPO DE INFORMAÇÕES (Sem o cabeçalho) ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(
                20.0,
              ), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ep.nome,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Icon(
                        Icons.flight_takeoff,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "${(ep.pais ?? ep.entidadeAbroad).toUpperCase()} • ${ep.comite.toUpperCase()}",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade500,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // TAG
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          precisaHospedagem
                              ? Icons.home_work_outlined
                              : Icons.check_circle_outline,
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          precisaHospedagem
                              ? "Precisa de Host"
                              : "Acomodação OK",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(), 
                  // CAIXA DE DATAS
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _DataColumn(
                          label: "Chegada",
                          data: _formatDateString(
                            ep.dataChegada ?? ep.dataRePresencial,
                          ),
                        ),
                        _DataColumn(
                          label: "Saída",
                          data: _formatDateString(
                            ep.dataPartida ?? ep.dataFinPresencial,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- RODAPÉ COM BOTÕES ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _abrirDetalhes,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Ver Detalhes",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // BOTÃO HOSPEDAR (Quadrado)
                Tooltip(
                  message: "Demonstrar Interesse",
                  child: SizedBox(
                    height: 54,
                    width: 72,
                    child: OutlinedButton(
                      onPressed: _isProcessing ? null : _toggleInteresse,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.other_houses_outlined,
                                  color: Colors.grey.shade700,
                                  size: 22,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Hospedar",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Sub-widget de colunas de data
class _DataColumn extends StatelessWidget {
  final String label;
  final String data;
  const _DataColumn({required this.label, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          data,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
