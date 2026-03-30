import 'package:aiesec_lar_global/features/host/interesses/widgets/aplicacao_timeline.dart';
import 'package:flutter/material.dart';
import 'package:aiesec_lar_global/data/models/aplicacao.dart';

class StatusAplicacaoSheet extends StatelessWidget {
  final Aplicacao aplicacao;

  const StatusAplicacaoSheet({super.key, required this.aplicacao});

  @override
  Widget build(BuildContext context) {
    final bool isCancelada = aplicacao.status == StatusAplicacao.cancelada;
    final bool isRejeitada = aplicacao.status == StatusAplicacao.rejeitada;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
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
                "Status da Aplicação",
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Sua Jornada como Família Anfitriã",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Acompanhe o status da sua candidatura e fique por dentro dos próximos passos para receber ${aplicacao.epNome} em seu lar.",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 32),

                  if (isCancelada || isRejeitada)
                    Container(
                      margin: const EdgeInsets.only(bottom: 32),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.cancel_outlined,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isCancelada
                                  ? "Esta aplicação foi cancelada. Retome o interesse na aba 'Cancelados' se desejar continuar."
                                  : "A candidatura para este intercambista não foi aprovada pelo comitê. Você pode aplicar para outras oportunidades disponíveis!",
                              style: TextStyle(
                                color: Colors.red.shade900,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    // CHAMAMOS O NOVO WIDGET AQUI:
                    child: AplicacaoTimeline(aplicacao: aplicacao),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
