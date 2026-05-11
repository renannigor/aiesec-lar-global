import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Imports Core
import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/data/models/nps_host.dart';

class NpsDetalhesSheet extends StatelessWidget {
  final NpsHost nps;

  const NpsDetalhesSheet({super.key, required this.nps});

  @override
  Widget build(BuildContext context) {
    Color corNota = Colors.orange;
    if (nps.notaNps >= 9) {
      corNota = Colors.green;
    } else if (nps.notaNps <= 6) {
      corNota = Colors.red;
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- CABEÇALHO ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Avaliação Completa",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  splashRadius: 24,
                ),
              ],
            ),
          ),

          // --- CORPO ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Destaque da Nota
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: corNota.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          nps.notaNps.toString(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: corNota,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Nota NPS do Host",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            DateFormat(
                              "Enviado em dd 'de' MMMM 'de' yyyy",
                            ).format(nps.criadoEm),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  _buildSectionTitle("1. Identificação"),
                  _buildInfoRow("Nome do Host:", nps.nomeHost),
                  _buildInfoRow("Hospedou:", nps.nomeIntercambista),
                  _buildInfoRow(
                    "Primeira vez sendo Host?",
                    nps.primeiraVezHost,
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle("2. Suporte da AIESEC"),
                  _buildInfoRow(
                    "Termo de Hospedagem assinado?",
                    nps.termoFirmado,
                  ),
                  _buildInfoRow(
                    "Acompanhamento (Contato):",
                    nps.avaliacaoAcompanhamento,
                  ),
                  _buildInfoRow(
                    "Comunicação Clara sobre Regras:",
                    nps.comunicacaoClara,
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle("3. Sobre a Experiência"),
                  _buildInfoRow(
                    "Objetivos foram alcançados?",
                    nps.objetivosAlcancados,
                  ),
                  _buildInfoBlock(
                    "O que mais gostou/aprendeu:",
                    nps.oQueAprendeu,
                  ),
                  _buildInfoBlock(
                    "O que a AIESEC deve melhorar:",
                    nps.oQueMelhorar,
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle("4. Futuro e Indicações"),
                  _buildInfoRow(
                    "Hospedaria novamente?",
                    nps.serHostNovamente,
                    corDestaque: nps.serHostNovamente == 'Sim'
                        ? Colors.green
                        : Colors.red,
                  ),
                  if (nps.motivoNaoTalvez != null &&
                      nps.motivoNaoTalvez!.isNotEmpty)
                    _buildInfoBlock("Motivo:", nps.motivoNaoTalvez!),
                  if (nps.indicacaoAmigo != null &&
                      nps.indicacaoAmigo!.isNotEmpty)
                    _buildInfoBlock(
                      "Indicação (Nome/Celular):",
                      nps.indicacaoAmigo!,
                    ),

                  const SizedBox(height: 24),
                  _buildSectionTitle("5. Memórias"),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          nps.fotoPodioId != null
                              ? Icons.image
                              : Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          nps.fotoPodioId != null
                              ? "Foto anexada no CRM (Podio)."
                              : "O Host não enviou fotos nesta avaliação.",
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Divider(color: Colors.grey.shade300, thickness: 1),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? corDestaque}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: corDestaque ?? Colors.black87,
                fontSize: 13,
                fontWeight: corDestaque != null
                    ? FontWeight.bold
                    : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBlock(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
