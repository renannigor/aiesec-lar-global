import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Imports Core
import 'package:aiesec_lar_global/core/widgets/responsive.dart';
// Imports Data
import 'package:aiesec_lar_global/data/models/nps_host.dart';

class NpsExpansionCard extends StatelessWidget {
  final NpsHost nps;

  const NpsExpansionCard({super.key, required this.nps});

  @override
  Widget build(BuildContext context) {
    Color corNota = Colors.orange;
    if (nps.notaNps >= 9) {
      corNota = Colors.green;
    } else if (nps.notaNps <= 6) {
      corNota = Colors.red;
    }

    final isMobile = Responsive.isMobile(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        // Remove as linhas padrão do ExpansionTile
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 24,
          ),
          iconColor: Colors.grey.shade400,
          collapsedIconColor: Colors.grey.shade400,

          // --- CABEÇALHO DA LINHA ---
          title: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey.shade100,
                child: const Icon(Icons.person, size: 16, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nps.nomeHost,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Host de: ${nps.nomeIntercambista} • ${DateFormat("dd/MM/yyyy").format(nps.criadoEm)}",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // --- BADGE DE NOTA NPS ---
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: corNota.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: corNota.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: corNota, size: 14),
                const SizedBox(width: 4),
                Text(
                  nps.notaNps.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: corNota,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // --- CONTEÚDO EXPANDIDO (Os Detalhes) ---
          children: [
            const Divider(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Coluna 1: Dados Objetivos
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMiniInfoRow(
                        "Hospedaria Novamente?",
                        nps.serHostNovamente,
                        corDestaque: nps.serHostNovamente == 'Sim'
                            ? Colors.green
                            : Colors.red,
                      ),
                      _buildMiniInfoRow(
                        "Primeira vez Host?",
                        nps.primeiraVezHost,
                      ),
                      _buildMiniInfoRow("Termo Firmado?", nps.termoFirmado),
                      _buildMiniInfoRow(
                        "Acompanhamento:",
                        nps.avaliacaoAcompanhamento,
                      ),
                      _buildMiniInfoRow("Regras Claras:", nps.comunicacaoClara),
                      _buildMiniInfoRow(
                        "Objetivos Atingidos:",
                        nps.objetivosAlcancados,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Coluna 2: Relatos Textuais (Oculta no mobile para empilhar)
                Expanded(
                  flex: isMobile ? 0 : 2,
                  child: isMobile ? const SizedBox.shrink() : _buildRelatos(),
                ),
              ],
            ),
            // No mobile, joga os relatos para baixo da linha
            if (isMobile) ...[const SizedBox(height: 16), _buildRelatos()],
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES PARA A ÁREA EXPANDIDA ---
  Widget _buildRelatos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextBlock(
          "O que mais gostou / aprendeu:",
          nps.oQueAprendeu,
          Colors.blue,
        ),
        const SizedBox(height: 16),
        _buildTextBlock("Ponto de melhoria:", nps.oQueMelhorar, Colors.orange),

        if (nps.motivoNaoTalvez != null && nps.motivoNaoTalvez!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildTextBlock(
            "Motivo (Não/Talvez hospedar novamente):",
            nps.motivoNaoTalvez!,
            Colors.red,
          ),
        ],

        if (nps.indicacaoAmigo != null && nps.indicacaoAmigo!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildTextBlock("Indicação:", nps.indicacaoAmigo!, Colors.green),
        ],

        if (nps.fotoPodioId != null) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.image, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                "Host enviou foto. Disponível no CRM (Podio).",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildMiniInfoRow(String label, String value, {Color? corDestaque}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
          ),
          Text(
            value,
            style: TextStyle(
              color: corDestaque ?? Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextBlock(
    String title,
    String content,
    MaterialColor themeColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: themeColor.shade700,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            content,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
