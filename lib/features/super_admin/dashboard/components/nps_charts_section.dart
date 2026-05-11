import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// Imports Core
import 'package:aiesec_lar_global/core/theme/app_colors.dart';
// Imports Data
import 'package:aiesec_lar_global/data/models/nps_host.dart';

class NpsChartsSection extends StatelessWidget {
  final List<NpsHost> avaliacoes;

  const NpsChartsSection({super.key, required this.avaliacoes});

  @override
  Widget build(BuildContext context) {
    if (avaliacoes.isEmpty) return const SizedBox.shrink();

    // --- AGREGADORES DE DADOS ---
    final mapHospedaria = _contar(avaliacoes, (nps) => nps.serHostNovamente);
    final mapObjetivos = _contar(avaliacoes, (nps) => nps.objetivosAlcancados);
    final mapComunicacao = _contar(avaliacoes, (nps) => nps.comunicacaoClara);
    // NOVO: Gráfico de Acompanhamento
    final mapAcompanhamento = _contar(
      avaliacoes,
      (nps) => nps.avaliacaoAcompanhamento,
    );

    // Para o gráfico de barras, vamos agrupar o NPS em 3 categorias clássicas
    int promotores = avaliacoes.where((n) => n.notaNps >= 9).length;
    int neutros = avaliacoes
        .where((n) => n.notaNps == 7 || n.notaNps == 8)
        .length;
    int detratores = avaliacoes.where((n) => n.notaNps <= 6).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsividade do Grid de Gráficos
        int crossAxisCount = 1;
        if (constraints.maxWidth > 1200) {
          crossAxisCount =
              2; // Fica muito bonito 2 gráficos grandes por linha no Desktop
        }

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: constraints.maxWidth > 1200 ? 1.5 : 1.0,
          children: [
            // 1. Gráfico de Barras: Distribuição do NPS
            _buildBarChartCard(
              title: "Distribuição das Notas (NPS)",
              dados: {
                'Promotores': promotores,
                'Neutros': neutros,
                'Detratores': detratores,
              },
              cores: {
                'Promotores': Colors.green,
                'Neutros': Colors.orange,
                'Detratores': Colors.red,
              },
            ),

            // 2. Gráfico de Pizza: Hospedaria Novamente
            _buildPieChartCard(
              title: "Hospedaria Novamente?",
              dados: mapHospedaria,
              cores: {
                'Sim': Colors.green,
                'Talvez': Colors.amber,
                'Não': Colors.red,
              },
            ),

            // 3. Gráfico de Pizza: Qualidade do Acompanhamento (NOVO)
            _buildPieChartCard(
              title: "Qualidade do Acompanhamento",
              dados: mapAcompanhamento,
              cores: {
                'Excelente': Colors.green,
                'Bom': Colors.blue,
                'Regular': Colors.orange,
                'Ruim': Colors.red,
              },
            ),

            // 4. Gráfico de Pizza: Objetivos Alcançados
            _buildPieChartCard(
              title: "Objetivos foram alcançados?",
              dados: mapObjetivos,
              cores: {
                'Sim': Colors.blue,
                'Parcialmente': Colors.amber,
                'Não': Colors.red,
              },
            ),

            // 5. Gráfico de Pizza: Comunicação Clara
            _buildPieChartCard(
              title: "Comunicação Clara das Regras",
              dados: mapComunicacao,
              cores: {
                'Sim': Colors.teal,
                'Parcialmente': Colors.orange,
                'Não': Colors.red,
              },
            ),
          ],
        );
      },
    );
  }

  // Função utilitária para contar frequência
  Map<String, int> _contar(
    List<NpsHost> lista,
    String Function(NpsHost) seletor,
  ) {
    final mapa = <String, int>{};
    for (var item in lista) {
      final chave = seletor(item);
      mapa[chave] = (mapa[chave] ?? 0) + 1;
    }
    return mapa;
  }

  // ==========================================================
  // COMPONENTE: GRÁFICO DE PIZZA (PIE CHART)
  // ==========================================================
  Widget _buildPieChartCard({
    required String title,
    required Map<String, int> dados,
    required Map<String, Color> cores,
  }) {
    int total = dados.values.fold(0, (sum, val) => sum + val);

    List<PieChartSectionData> sections = dados.entries.map((entry) {
      final isZero = entry.value == 0;
      final porcentagem = total > 0 ? (entry.value / total * 100) : 0.0;

      return PieChartSectionData(
        color: cores[entry.key] ?? Colors.grey,
        value: entry.value.toDouble(),
        title: isZero ? '' : '${porcentagem.toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return _buildCardBase(
      title: title,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: sections,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: dados.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: cores[entry.key] ?? Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "${entry.key} (${entry.value})",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // COMPONENTE: GRÁFICO DE BARRAS (BAR CHART)
  // ==========================================================
  Widget _buildBarChartCard({
    required String title,
    required Map<String, int> dados,
    required Map<String, Color> cores,
  }) {
    double maxY = dados.values.isEmpty
        ? 10
        : dados.values.reduce(max).toDouble() + 2;

    List<BarChartGroupData> barGroups = [];
    int xIndex = 0;
    final keys = dados.keys.toList();

    for (var key in keys) {
      barGroups.add(
        BarChartGroupData(
          x: xIndex,
          barRods: [
            BarChartRodData(
              toY: dados[key]!.toDouble(),
              color: cores[key] ?? AppColors.primary,
              width: 32, // Largura da barra
              borderRadius: BorderRadius.circular(4),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxY,
                color: Colors.grey.shade100, 
              ),
            ),
          ],
          showingTooltipIndicators: [0],
        ),
      );
      xIndex++;
    }

    return _buildCardBase(
      title: title,
      child: Padding(
        padding: const EdgeInsets.only(top: 24.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
            barTouchData: BarTouchData(
              enabled: false,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (group) =>
                    Colors.transparent, // Fundo transparente pro tooltip
                tooltipPadding: EdgeInsets.zero,
                tooltipMargin: 8,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    rod.toY.round().toString(),
                    const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    if (value.toInt() < keys.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          keys[value.toInt()],
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ), // Esconde eixo Y
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: const FlGridData(
              show: false,
            ), // Remove as linhas de grade
            borderData: FlBorderData(show: false), // Remove a borda do gráfico
            barGroups: barGroups,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // BASE DO CARD (Design consistente)
  // ==========================================================
  Widget _buildCardBase({required String title, required Widget child}) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(child: child),
        ],
      ),
    );
  }
}
