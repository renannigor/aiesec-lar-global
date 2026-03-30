import 'package:flutter/material.dart';
import 'package:aiesec_lar_global/data/models/aplicacao.dart';

class AplicacaoTimeline extends StatelessWidget {
  final Aplicacao aplicacao;

  const AplicacaoTimeline({super.key, required this.aplicacao});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> passos = [
      {
        'status': StatusAplicacao.pendente,
        'titulo': 'Inscrição recebida',
        'descricao': 'Recebemos a sua aplicação para ser família anfitriã.',
      },
      {
        'status': StatusAplicacao.entrevistaAiesec,
        'titulo': 'Encontro com a AIESEC',
        'descricao':
            'Conversa inicial para nos conhecermos melhor e esclarecer dúvidas.',
      },
      {
        'status': StatusAplicacao.aprovada,
        'titulo': 'Candidatura aprovada',
        'descricao': 'Perfil aprovado para seguir no processo de pareamento.',
      },
      {
        'status': StatusAplicacao.encontroEp,
        'titulo': 'Encontro com o intercambista',
        'descricao': 'Reunião entre família e estudante para se conhecerem.',
      },
      {
        'status': StatusAplicacao.confirmada,
        'titulo': 'Confirmação da hospedagem',
        'descricao': 'Ambas as partes confirmam interesse na hospedagem.',
      },
      {
        'status': StatusAplicacao.assinaturaTermo,
        'titulo': 'Assinatura do termo de hospedagem',
        'descricao': 'Formalização do compromisso de acolhimento.',
      },
      {
        'status': StatusAplicacao.hospedando,
        'titulo': 'Intercambista hospedado',
        'descricao': 'Período de convivência entre a família e o estudante.',
      },
      {
        'status': StatusAplicacao.concluida,
        'titulo': 'Experiência concluída',
        'descricao': 'Fim oficial da jornada como anfitrião.',
      },
    ];

    int currentIndex = passos.indexWhere(
      (p) => p['status'] == aplicacao.status,
    );

    if (currentIndex == -1) currentIndex = 0;

    return Column(
      children: List.generate(passos.length, (index) {
        final passo = passos[index];
        final bool isCompleted = index <= currentIndex;
        final bool isLast = index == passos.length - 1;

        // Só pinta de verde se completou E se não for um processo interrompido
        final bool paintGreen =
            isCompleted &&
            aplicacao.status != StatusAplicacao.cancelada &&
            aplicacao.status != StatusAplicacao.rejeitada;

        return _TimelineStep(
          title: passo['titulo'],
          description: passo['descricao'],
          isActive: paintGreen,
          isLast: isLast,
        );
      }),
    );
  }
}

// O componente visual do degrau (mantemos privado neste arquivo, pois só a Timeline usa)
class _TimelineStep extends StatelessWidget {
  final String title;
  final String description;
  final bool isActive;
  final bool isLast;

  const _TimelineStep({
    required this.title,
    required this.description,
    required this.isActive,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // COLUNA ESQUERDA: Bolinha e Linha
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isActive ? Colors.green : Colors.grey.shade200,
                    ),
                  ),
              ],
            ),
          ),
          // COLUNA DIREITA: Textos
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.black87 : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isActive
                          ? Colors.grey.shade700
                          : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
