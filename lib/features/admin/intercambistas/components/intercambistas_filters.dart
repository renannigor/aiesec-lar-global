import 'package:aiesec_lar_global/features/admin/intercambistas/intercambistas_constantes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IntercambistasFilters extends StatelessWidget {
  final bool isMobile;
  final String? filtroStatus;
  final String filtroHospedagem;
  final DateTime? filtroDataInicio;
  final DateTime? filtroDataTermino;
  final Function(String?) onStatusChanged;
  final Function(String?) onHospedagemChanged;
  final Function(DateTime?, bool isInicio) onDateChanged;
  final VoidCallback onClear;

  const IntercambistasFilters({
    super.key,
    required this.isMobile,
    required this.filtroStatus,
    required this.filtroHospedagem,
    required this.filtroDataInicio,
    required this.filtroDataTermino,
    required this.onStatusChanged,
    required this.onHospedagemChanged,
    required this.onDateChanged,
    required this.onClear,
  });

  Future<void> _pickDate(BuildContext context, bool isInicio) async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (d != null) {
      onDateChanged(d, isInicio);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double fieldWidth = isMobile
        ? (MediaQuery.of(context).size.width / 2) - 24
        : 130;
    const Color borderColor = Color(0xFFEAEAEA);

    final widgets = [
      SizedBox(
        width: fieldWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Status Podio",
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(6),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: filtroStatus,
                  hint: const Text("Todos", style: TextStyle(fontSize: 13)),
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                  items: AppConstants.statusPodio
                      .map(
                        (e) => DropdownMenuItem(
                          value: e == 'Todos' ? null : e,
                          child: Text(e),
                        ),
                      )
                      .toList(),
                  onChanged: onStatusChanged,
                ),
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        width: fieldWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Precisa de Host?",
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(6),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: filtroHospedagem,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                  items: AppConstants.filtroSimNao
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: onHospedagemChanged,
                ),
              ),
            ),
          ],
        ),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Período (Início)",
            style: TextStyle(fontSize: 11, color: Colors.transparent),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: fieldWidth,
            height: 38,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.date_range, size: 16, color: Colors.grey),
              label: Text(
                filtroDataInicio == null
                    ? "Início >="
                    : DateFormat('dd/MM/yyyy').format(filtroDataInicio!),
                style: const TextStyle(fontSize: 12, color: Colors.black87),
                overflow: TextOverflow.ellipsis,
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                backgroundColor: Colors.white,
                side: const BorderSide(color: borderColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () => _pickDate(context, true),
            ),
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Período (Fim)",
            style: TextStyle(fontSize: 11, color: Colors.transparent),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: fieldWidth,
            height: 38,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.date_range, size: 16, color: Colors.grey),
              label: Text(
                filtroDataTermino == null
                    ? "Fim <="
                    : DateFormat('dd/MM/yyyy').format(filtroDataTermino!),
                style: const TextStyle(fontSize: 12, color: Colors.black87),
                overflow: TextOverflow.ellipsis,
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                backgroundColor: Colors.white,
                side: const BorderSide(color: borderColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () => _pickDate(context, false),
            ),
          ),
        ],
      ),
      if (filtroStatus != null ||
          filtroHospedagem != 'Todos' ||
          filtroDataInicio != null ||
          filtroDataTermino != null)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("", style: TextStyle(fontSize: 11)),
            const SizedBox(height: 4),
            SizedBox(
              height: 38,
              child: TextButton(
                onPressed: onClear,
                child: const Text(
                  "Limpar",
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
    ];

    if (isMobile) {
      return Wrap(spacing: 12, runSpacing: 12, children: widgets);
    } else {
      return Expanded(
        child: Wrap(
          alignment: WrapAlignment.end,
          spacing: 12,
          runSpacing: 12,
          children: widgets,
        ),
      );
    }
  }
}
