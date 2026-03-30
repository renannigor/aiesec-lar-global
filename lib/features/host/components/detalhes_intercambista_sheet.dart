import 'package:aiesec_lar_global/data/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// --- IMPORTS DO FIREBASE ---
import 'package:aiesec_lar_global/data/models/aplicacao.dart';
import 'package:aiesec_lar_global/data/services/aplicacao_service.dart';
import 'package:aiesec_lar_global/core/utils/snackbar.dart';

import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/data/models/intercambista/intercambista.dart';
import 'package:aiesec_lar_global/data/models/oportunidade.dart';
import 'package:aiesec_lar_global/data/services/oportunidade_service.dart';

class DetalhesIntercambistaSheet extends StatefulWidget {
  final Intercambista intercambista;

  const DetalhesIntercambistaSheet({super.key, required this.intercambista});

  @override
  State<DetalhesIntercambistaSheet> createState() =>
      _DetalhesIntercambistaSheetState();
}

class _DetalhesIntercambistaSheetState
    extends State<DetalhesIntercambistaSheet> {
  bool _interesseDemonstrado = false;
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _verificarInteresseAtivo();
  }

  Future<void> _verificarInteresseAtivo() async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final temInteresse = await AplicacaoService.instance
          .jaDemonstrouInteresse(
            hostUid: user.uid,
            intercambistaId: widget.intercambista.epId,
          );

      if (mounted) {
        setState(() {
          _interesseDemonstrado = temInteresse;
        });
      }
    } catch (e) {
      debugPrint("Erro ao verificar status inicial: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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

    final user = AuthService.instance.currentUser;
    if (user == null) {
      SnackbarUtils.showInfo(
        "Você precisa estar logado para demonstrar interesse.",
      );
      return;
    }

    setState(() => _isProcessing = true);

    final ep = widget.intercambista;
    final hostUid = user.uid;

    try {
      // Puxa o registro (se existir)
      final aplicacoes = await AplicacaoService.instance.getAplicacaoDoHost(
        hostUid: hostUid,
        intercambistaId: ep.epId,
      );

      if (aplicacoes.isEmpty) {
        // CENÁRIO 1: Primeira vez! Não tem registro nenhum no banco.
        final novaAplicacao = Aplicacao(
          aplicacaoId:
              '${hostUid}_${ep.epId}', // ID determinístico para evitar duplicação
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

        // Usando o método de salvar (upsert)
        await AplicacaoService.instance.criarAplicacao(
          aplicacao: novaAplicacao,
        );

        if (mounted) {
          setState(() => _interesseDemonstrado = true);
          SnackbarUtils.showSuccess("Interesse manifestado para ${ep.nome}!");
        }
      } else {
        // Se a lista não é vazia, pegamos o único registro que existe lá.
        final aplicacaoExistente = aplicacoes.first;

        if (aplicacaoExistente.status == StatusAplicacao.cancelada) {
          // CENÁRIO 2: Ele já tinha cancelado no passado. Vamos apenas RETOMAR.
          await AplicacaoService.instance.atualizarStatusAplicacao(
            aplicacaoId: aplicacaoExistente.aplicacaoId,
            novoStatus: StatusAplicacao.pendente,
          );

          if (mounted) {
            setState(() => _interesseDemonstrado = true);
            SnackbarUtils.showSuccess("Interesse retomado para ${ep.nome}!");
          }
        } else {
          // CENÁRIO 3: Ele está com interesse ativo (pendente, aprovado, etc). Vamos CANCELAR.
          await AplicacaoService.instance.atualizarStatusAplicacao(
            aplicacaoId: aplicacaoExistente.aplicacaoId,
            novoStatus: StatusAplicacao.cancelada,
          );

          if (mounted) {
            setState(() => _interesseDemonstrado = false);
            SnackbarUtils.showInfo("Interesse removido para ${ep.nome}.");
          }
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showInfo("Erro ao atualizar interesse.");
      }
      debugPrint("Erro: $e");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ep = widget.intercambista;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F8),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 8, top: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                "Perfil do Intercambista",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black54),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeaderCard(ep),
                  const SizedBox(height: 16),
                  _buildCardWrapper(
                    title: "Informações Pessoais",
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildInfoBlock(
                                "Idade",
                                ep.idade != null
                                    ? "${ep.idade} anos"
                                    : "Não informada",
                              ),
                            ),
                            Expanded(
                              child: _buildInfoBlock(
                                "Nacionalidade",
                                ep.nacionalidade ?? "Não informada",
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildInfoBlock(
                                "País de Origem",
                                ep.pais ?? ep.entidadeAbroad,
                              ),
                            ),
                            Expanded(
                              child: _buildInfoBlock(
                                "Idiomas",
                                (ep.idiomas != null && ep.idiomas!.isNotEmpty)
                                    ? ep.idiomas!.join(', ')
                                    : "Não informados",
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildInfoBlock(
                                "Necessidade de Acomodação",
                                ep.precisaHospedagem
                                    ? "Sim, precisa de Host"
                                    : "Não precisa",
                              ),
                            ),
                            Expanded(
                              child: _buildInfoBlock(
                                "Interesses / Hobbies",
                                (ep.interesses != null &&
                                        ep.interesses!.isNotEmpty)
                                    ? ep.interesses!.join(', ')
                                    : "Não informados",
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (ep.infosPessoais != null) ...[
                    _buildCardWrapper(
                      title: "Detalhes de Convivência",
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildInfoBlock(
                              "Dados Adicionais",
                              "Adapte com atributos reais",
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (ep.descricoes != null) ...[
                    _buildCardWrapper(
                      title: "Sobre o Intercambista",
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoBlock(
                            "Descrição",
                            "Adapte com atributos reais",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _buildCardWrapper(
                    title: "Formação Acadêmica",
                    child: _buildInfoBlock(
                      "Grau / Curso",
                      ep.formacao ?? "Não informada",
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildProjetoCard(ep),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(Intercambista ep) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              ep.nome.isNotEmpty ? ep.nome[0].toUpperCase() : '?',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
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
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "Indo para ${ep.comite}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- BOTÃO SUTIL (Amarelinho) ---
          Tooltip(
            message: _interesseDemonstrado
                ? "Remover interesse"
                : "Demonstrar interesse",
            child: InkWell(
              onTap: (_isLoading || _isProcessing) ? null : _toggleInteresse,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _interesseDemonstrado
                      ? Colors.amber.shade50
                      : Colors.transparent,
                  border: Border.all(
                    color: _interesseDemonstrado
                        ? Colors.amber.shade600
                        : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    if (_isLoading || _isProcessing)
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Icon(
                        _interesseDemonstrado
                            ? Icons.other_houses
                            : Icons.other_houses_outlined,
                        color: _interesseDemonstrado
                            ? Colors.amber.shade600
                            : Colors.grey.shade600,
                        size: 24,
                      ),
                    const SizedBox(height: 4),
                    Text(
                      _interesseDemonstrado ? "Interesse Salvo" : "Hospedar",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _interesseDemonstrado
                            ? Colors.amber.shade600
                            : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjetoCard(Intercambista ep) {
    if (ep.opId.isEmpty || ep.opId == 'Não preenchido') {
      return _buildCardWrapper(
        title: "Informações do Projeto",
        child: const Text(
          "Oportunidade não vinculada a este EP.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return FutureBuilder<Oportunidade?>(
      future: OportunidadeService.instance.getOportunidadePorId(ep.opId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildCardWrapper(
            title: "Informações do Projeto",
            child: const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return _buildCardWrapper(
            title: "Informações do Projeto",
            child: const Text(
              "Detalhes do projeto indisponíveis no momento.",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final projeto = snapshot.data!;
        final chegada = _formatDateString(
          ep.dataChegada ?? ep.dataRePresencial,
        );
        final saida = _formatDateString(ep.dataPartida ?? ep.dataFinPresencial);

        return _buildCardWrapper(
          title: "Informações do Projeto",
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildInfoBlock(
                      "Organização / ONG",
                      projeto.organizacao,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoBlock("Vaga de Trabalho", projeto.projeto),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildInfoBlock(
                      "Duração Total",
                      "${projeto.duracaoTotal} semanas",
                    ),
                  ),
                  Expanded(child: Container()),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Divider(),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildInfoBlock("Data de Chegada", chegada)),
                  Expanded(child: _buildInfoBlock("Data de Saída", saida)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardWrapper({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoBlock(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
