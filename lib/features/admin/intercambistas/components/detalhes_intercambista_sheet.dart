import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/data/models/intercambista/intercambista.dart';

class DetalhesIntercambistaSheets extends StatelessWidget {
  final Intercambista intercambista;

  const DetalhesIntercambistaSheets({super.key, required this.intercambista});

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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CABEÇALHO DO BOTTOM SHEET
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Detalhes do Intercambista",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  splashRadius: 24,
                ),
              ],
            ),
          ),

          // CORPO ROLÁVEL
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. CABEÇALHO PRINCIPAL
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.1,
                        ),
                        child: Text(
                          intercambista.nome.isNotEmpty
                              ? intercambista.nome[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 32,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              intercambista.nome,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.public,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "${intercambista.pais ?? intercambista.entidadeAbroad} • ${intercambista.idade ?? '?'} anos",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                    overflow: TextOverflow.ellipsis,
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
                                  fontSize: 11,
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

                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 32),

                  // 2. DADOS DO INTERCÂMBIO
                  _buildSectionTitle("Dados do Projeto (Podio)"),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 40,
                    runSpacing: 20,
                    children: [
                      _buildInfoColumn(
                        "Comitê Anfitrião",
                        intercambista.comite,
                      ),
                      _buildInfoColumn("Área de Atuação", intercambista.area),
                      _buildInfoColumn("OP ID", intercambista.opId),
                      _buildInfoColumn(
                        "Período do Projeto",
                        "${_formatDateString(intercambista.dataRePresencial)} até ${_formatDateString(intercambista.dataFinPresencial)}",
                      ),
                      // --- NOVO CAMPO DE VOOS AQUI ---
                      _buildInfoColumn(
                        "Período de Hospedagem (Voos)",
                        "${_formatDateString(intercambista.dataChegada ?? intercambista.dataRePresencial)} até ${_formatDateString(intercambista.dataPartida ?? intercambista.dataFinPresencial)}",
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
                  _buildTextField(
                    "Hobbies",
                    intercambista.descricoes?.hobbies ?? '',
                  ),
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

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
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
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
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
        style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
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
              fontSize: 14,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text.isEmpty ? "Não informado." : text,
            style: const TextStyle(
              height: 1.5,
              color: Color(0xFF4B5563),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInfo(String label, bool value) {
    return Row(
      children: [
        Icon(
          value ? Icons.cancel : Icons.check_circle,
          size: 18,
          color: value ? Colors.red : Colors.green,
        ),
        const SizedBox(width: 6),
        Text(
          "$label: ${value ? 'Sim' : 'Não'}",
          style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
        ),
      ],
    );
  }
}
