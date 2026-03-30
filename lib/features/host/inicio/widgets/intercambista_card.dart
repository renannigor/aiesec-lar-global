import 'package:aiesec_lar_global/data/services/auth_service.dart';
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

// Importando a tela de detalhes para abri-la diretamente do card
import 'package:aiesec_lar_global/features/host/components/detalhes_intercambista_sheet.dart';

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
          // Calcula quanto falta para exibir uma mensagem mais amigável
          final atual = (progresso * 100).toInt();
          SnackbarUtils.showError(
            "Seu perfil está $atual% completo. Preencha pelo menos 80% na aba 'Meu Perfil' para demonstrar interesse!",
          );
          setState(() => _isProcessing = false);
          return; // Para a execução aqui e não registra o interesse
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
          widget.onInteresseSalvo(); // REDIRECIONA
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
            widget.onInteresseSalvo(); // REDIRECIONA TBM!
          }
        } else {
          // Cancela se já estava ativo
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
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
              ),
              child: Icon(
                Icons.person_outline,
                size: 80,
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ep.nome,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.flight_takeoff,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "${ep.pais ?? ep.entidadeAbroad} • ${ep.comite}",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          precisaHospedagem
                              ? Icons.home_work_outlined
                              : Icons.check_circle_outline,
                          size: 12,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          precisaHospedagem
                              ? "Precisa de Host"
                              : "Acomodação OK",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade100),
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

          // --- 3. RODAPÉ COM BOTÕES ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _abrirDetalhes,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Ver Detalhes",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                Tooltip(
                  message: "Demonstrar Interesse",
                  child: InkWell(
                    onTap: _isProcessing ? null : _toggleInteresse,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          if (_isProcessing)
                            const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            Icon(
                              Icons.other_houses_outlined,
                              color: Colors.grey.shade600,
                              size: 24,
                            ),
                          const SizedBox(height: 4),
                          Text(
                            "Hospedar",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade500,
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
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          data,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
