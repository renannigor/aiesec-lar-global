import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/core/widgets/responsive.dart';
import 'package:aiesec_lar_global/data/models/intercambista/intercambista.dart';
import 'package:aiesec_lar_global/data/services/aplicacao_service.dart';

class IntercambistaCard extends StatelessWidget {
  final Intercambista intercambista;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewDetails;
  final VoidCallback onViewApplicants;

  const IntercambistaCard({
    super.key,
    required this.intercambista,
    required this.onEdit,
    required this.onDelete,
    required this.onViewDetails,
    required this.onViewApplicants,
  });

  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: _buildCard(context, isMobile: true),
      desktop: _buildCard(context, isMobile: false),
    );
  }

  Widget _buildCard(BuildContext context, {required bool isMobile}) {
    // Ajuste aqui para o nome do status que vem do Podio
    final isDisponivel =
        intercambista.status.toLowerCase() == 'approved' ||
        intercambista.status.toLowerCase() == 'disponivel';
    final statusColor = isDisponivel ? Colors.green : Colors.orange;
    final statusBg = statusColor.withValues(alpha: 0.1);

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isMobile),
          const SizedBox(height: 12),
          _buildInfoWrap(),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrgInfo(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusChip(statusBg, statusColor),
                    Row(
                      children: [
                        _buildActionButton(
                          "Aplicantes",
                          onViewApplicants,
                          isOutlined: true,
                          isCompact: true,
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          "Detalhes",
                          onViewDetails,
                          isOutlined: false,
                          isCompact: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(child: _buildOrgInfo()),
                _buildStatusChip(statusBg, statusColor),
                const SizedBox(width: 24),
                _buildActionButton(
                  "Ver Aplicantes",
                  onViewApplicants,
                  isOutlined: true,
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  "Ver Detalhes",
                  onViewDetails,
                  isOutlined: false,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                intercambista.nome,
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              FutureBuilder<int>(
                future: AplicacaoService.instance.getQuantidadeAplicacoesAtivas(
                  intercambista.epId,
                ),
                builder: (context, snapshot) {
                  final count = snapshot.data ?? 0;
                  return Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        "$count interessados",
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.edit_outlined,
                size: 20,
                color: Colors.grey[600],
              ),
              onPressed: onEdit,
              tooltip: "Editar",
              splashRadius: 20,
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                size: 20,
                color: Colors.red[300],
              ),
              onPressed: onDelete,
              tooltip: "Excluir",
              splashRadius: 20,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoWrap() {
    return Wrap(
      spacing: 24,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.public, size: 20, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              // Usa o país manual, se nulo usa a Entidade Abroad do Podio
              intercambista.pais ?? intercambista.entidadeAbroad,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        _buildIconText(Icons.cake, "${intercambista.idade ?? '?'} anos"),
        _buildIconText(Icons.business_center, "Área: ${intercambista.area}"),
      ],
    );
  }

  Widget _buildOrgInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Período (Podio)",
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "${_formatDateString(intercambista.dataRePresencial)} até ${_formatDateString(intercambista.dataFinPresencial)}",
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF374151),
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildStatusChip(Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        intercambista.status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    VoidCallback onTap, {
    required bool isOutlined,
    bool isCompact = false,
  }) {
    final style = isOutlined
        ? OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.grey.shade300),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 12 : 16,
              vertical: 12,
            ),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 12 : 20,
              vertical: 12,
            ),
            elevation: 0,
          );

    final textStyle = TextStyle(
      color: isOutlined ? const Color(0xFF374151) : Colors.white,
      fontSize: isCompact ? 12 : 13,
      fontWeight: isOutlined ? FontWeight.normal : FontWeight.bold,
    );

    return isOutlined
        ? OutlinedButton(
            onPressed: onTap,
            style: style,
            child: Text(label, style: textStyle),
          )
        : ElevatedButton(
            onPressed: onTap,
            style: style,
            child: Text(label, style: textStyle),
          );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[400]),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
      ],
    );
  }

  // Função auxiliar para formatar strings de data que vêm do Podio
  String _formatDateString(String dateStr) {
    if (dateStr.isEmpty || dateStr == 'Não informado') return 'Não informado';
    try {
      final d = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(d);
    } catch (e) {
      return dateStr.split(' ')[0]; // Fallback
    }
  }
}
