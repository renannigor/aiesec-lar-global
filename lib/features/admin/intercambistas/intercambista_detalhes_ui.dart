import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/data/models/intercambista/intercambista.dart';

class IntercambistaDetalhesUI extends StatelessWidget {
  final Intercambista intercambista;

  const IntercambistaDetalhesUI({super.key, required this.intercambista});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Detalhes do Intercambista",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. CABEÇALHO PRINCIPAL
            Row(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    intercambista.nome.isNotEmpty
                        ? intercambista.nome[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 40,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        intercambista.nome,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.public,
                            size: 24,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${intercambista.pais ?? intercambista.entidadeAbroad} • ${intercambista.idade ?? '?'} anos",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Text(
                          intercambista.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 40),

            // 2. DADOS DO INTERCÂMBIO
            _buildSectionTitle("Dados do Projeto (Podio)"),
            const SizedBox(height: 16),
            Wrap(
              spacing: 40,
              runSpacing: 20,
              children: [
                _buildInfoColumn("Comitê Anfitrião", intercambista.comite),
                _buildInfoColumn("Área de Atuação", intercambista.area),
                _buildInfoColumn("OP ID", intercambista.opId),
                _buildInfoColumn(
                  "Período do Projeto",
                  "${_formatDateString(intercambista.dataRePresencial)} até ${_formatDateString(intercambista.dataFinPresencial)}",
                ),
                _buildInfoColumn(
                  "Período de Hospedagem (Voos)",
                  "${_formatDateString(intercambista.dataChegada)} até ${_formatDateString(intercambista.dataPartida)}",
                ),
              ],
            ),

            const SizedBox(height: 40),

            // 3. SOBRE O VOLUNTÁRIO
            _buildSectionTitle("Sobre o Voluntário"),
            const SizedBox(height: 16),
            _buildInfoRow(
              "Nacionalidade",
              intercambista.nacionalidade ?? 'Não informada',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              "Formação Acadêmica",
              intercambista.formacao ?? 'Não informada',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              "Idiomas",
              intercambista.idiomas?.join(", ") ?? 'Não informado',
            ),
            const SizedBox(height: 24),
            _buildTextField(
              "Um pouco sobre mim",
              intercambista.descricoes?.sobreMim ?? '',
            ),
            _buildTextField("Hobbies", intercambista.descricoes?.hobbies ?? ''),
            _buildTextField(
              "Motivação para o projeto",
              intercambista.descricoes?.motivacao ?? '',
            ),

            const SizedBox(height: 40),

            // 4. INFORMAÇÕES PESSOAIS & PREFERÊNCIAS
            _buildSectionTitle("Informações Pessoais (Para Host)"),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildCheckInfo(
                  "Fumante",
                  intercambista.infosPessoais?.fumante ?? false,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              "Alergias",
              (intercambista.infosPessoais?.alergias ?? '').isEmpty
                  ? "Nenhuma relatada"
                  : intercambista.infosPessoais!.alergias!,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              "Restrições Alimentares/Outras",
              (intercambista.infosPessoais?.restricoes ?? '').isEmpty
                  ? "Nenhuma relatada"
                  : intercambista.infosPessoais!.restricoes!,
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF111827),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 15, color: Color(0xFF374151)),
        children: [
          TextSpan(
            text: "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text.isEmpty ? "Não informado." : text,
            style: const TextStyle(height: 1.5, color: Color(0xFF4B5563)),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInfo(String label, bool value) {
    return Row(
      children: [
        Icon(
          value ? Icons.check_circle : Icons.cancel,
          size: 18,
          color: value ? Colors.red : Colors.green,
        ),
        const SizedBox(width: 6),
        Text(
          "$label: ${value ? 'Sim' : 'Não'}",
          style: const TextStyle(fontSize: 15, color: Color(0xFF374151)),
        ),
      ],
    );
  }
}
