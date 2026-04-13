import 'package:flutter/material.dart';
import 'package:aiesec_lar_global/data/models/usuario/preferencias_hospedagem.dart';
import 'package:aiesec_lar_global/core/widgets/boolean_selector.dart';
import 'package:aiesec_lar_global/core/widgets/multi_select_chips.dart';
import 'package:aiesec_lar_global/core/widgets/selector.dart';
import 'package:aiesec_lar_global/core/widgets/editor.dart';
import '../perfil_constantes.dart';

class FormPreferencias extends StatefulWidget {
  final PreferenciasHospedagem? prefsAtual;
  final String? expectativasAtual;

  final Function(PreferenciasHospedagem novasPrefs, String novasExpectativas)
  onChanged;

  const FormPreferencias({
    super.key,
    required this.prefsAtual,
    required this.expectativasAtual,
    required this.onChanged,
  });

  @override
  State<FormPreferencias> createState() => _FormPreferenciasState();
}

class _FormPreferenciasState extends State<FormPreferencias> {
  late bool fumantes;
  late String prefSexo;
  late List<String> idiomas;
  late List<String> aceitaRestricoes;
  late List<String> meses;
  late TextEditingController expectativasController;
  late TextEditingController outrosIdiomasController;

  @override
  void initState() {
    super.initState();
    final p =
        widget.prefsAtual ??
        PreferenciasHospedagem(
          restricaoFumantes: false,
          aceitaRestricaoAlimentar: [],
          preferenciaSexo: 'Indiferente',
          preferenciaMeses: [],
          preferenciaIdiomas: [],
        );
    fumantes = p.restricaoFumantes;
    prefSexo = p.preferenciaSexo;
    idiomas = List.from(p.preferenciaIdiomas);
    aceitaRestricoes = List.from(p.aceitaRestricaoAlimentar);
    meses = List.from(p.preferenciaMeses);

    expectativasController = TextEditingController(
      text: widget.expectativasAtual ?? "",
    );
    outrosIdiomasController = TextEditingController(
      text: p.outrosIdiomas ?? "",
    );
  }

  void _atualizar() {
    final novasPrefs = PreferenciasHospedagem(
      restricaoFumantes: fumantes,
      aceitaRestricaoAlimentar: aceitaRestricoes,
      preferenciaSexo: prefSexo,
      preferenciaMeses: meses,
      preferenciaIdiomas: idiomas,
      outrosIdiomas: idiomas.contains('Outros')
          ? outrosIdiomasController.text
          : null,
    );
    widget.onChanged(novasPrefs, expectativasController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Editor(
          controller: expectativasController,
          labelText:
              "Quais características o intercambista precisa ter para se encaixar nas suas expectativas?",
          hintText: "Ex: Independente, limpo...",
          keyboardType: TextInputType.multiline,
          onChanged: (_) => _atualizar(),
          isPassword: false,
          enabled: true,
        ),
        const SizedBox(height: 32),
        BooleanSelector(
          labelText: "Você possui restrição com fumantes?",
          value: fumantes,
          onChanged: (temRestricao) {
            setState(() => fumantes = temRestricao);
            _atualizar();
          },
        ),
        const SizedBox(height: 24),
        Selector(
          labelText: "Preferência em hospedar intercambista do sexo",
          value: prefSexo,
          items: const ['Indiferente', 'Masculino', 'Feminino'],
          onChanged: (val) {
            setState(() => prefSexo = val!);
            _atualizar();
          },
        ),
        const SizedBox(height: 24),
        MultiSelectChips(
          labelText: "Preferência por algum idioma?",
          allOptions: PerfilConstantes.idiomas,
          selectedOptions: idiomas,
          onChanged: (l) {
            setState(() => idiomas = l);
            _atualizar();
          },
        ),

        // NOVO: Condicional se marcar "Outros" nos idiomas
        if (idiomas.contains('Outros')) ...[
          const SizedBox(height: 24),
          Editor(
            controller: outrosIdiomasController,
            labelText: "Se você marcou 'outros', quais são eles?",
            hintText: "Ex: Italiano, Mandarim...",
            onChanged: (_) => _atualizar(),
            isPassword: false,
            enabled: true,
            keyboardType: TextInputType.text,
          ),
        ],

        const SizedBox(height: 24),
        MultiSelectChips(
          labelText:
              "Tem problema em hospedar pessoas com alguma restrição alimentar?",
          allOptions: PerfilConstantes.restricaoAlimentar,
          selectedOptions: aceitaRestricoes,
          onChanged: (l) {
            setState(() => aceitaRestricoes = l);
            _atualizar();
          },
        ),
        const SizedBox(height: 24),
        MultiSelectChips(
          labelText: "Preferência em receber intercambistas nos meses",
          allOptions: PerfilConstantes.meses,
          selectedOptions: meses,
          onChanged: (l) {
            setState(() => meses = l);
            _atualizar();
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
