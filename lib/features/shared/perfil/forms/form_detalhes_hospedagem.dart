import 'package:flutter/material.dart';
import 'package:aiesec_lar_global/data/models/usuario/detalhes_hospedagem.dart';
import 'package:aiesec_lar_global/core/widgets/editor.dart';
import 'package:aiesec_lar_global/core/widgets/selector.dart';
import 'package:aiesec_lar_global/core/widgets/boolean_selector.dart';
import 'package:aiesec_lar_global/core/widgets/multi_select_chips.dart';
import '../perfil_constantes.dart';

class FormDetalhesHospedagem extends StatefulWidget {
  final DetalhesHospedagem? detalhesAtual;
  final Function(DetalhesHospedagem novosDetalhes) onChanged;

  const FormDetalhesHospedagem({
    super.key,
    required this.detalhesAtual,
    required this.onChanged,
  });

  @override
  State<FormDetalhesHospedagem> createState() => _FormDetalhesHospedagemState();
}

class _FormDetalhesHospedagemState extends State<FormDetalhesHospedagem> {
  late bool podeOferecer;
  String? localDormir;
  bool? acessoAguaEnergia;
  late String tipoQuarto;
  late TextEditingController quartoCompartilhadoInfo;
  late bool acessoAreas;
  late String refeicoes;
  late String maxIntercambistas;
  late bool temAnimais;
  late TextEditingController detalhesAnimaisInfo;
  late List<String> comodidades;
  late List<String> periodos;
  late TextEditingController moradoresController;

  @override
  void initState() {
    super.initState();
    final d =
        widget.detalhesAtual ??
        DetalhesHospedagem(
          podeOferecerAcomodacao: false,
          tipoQuarto: 'Individual',
          acessoAreasComuns: true,
          refeicoesOferecidas: '1 alimentação',
          maxIntercambistas: '1',
          periodoHospedagem: [],
          temAnimais: false,
          comodidadesProximas: [],
          fotosUrl: [],
          descricaoMoradores: "",
        );

    podeOferecer = d.podeOferecerAcomodacao;
    localDormir = d.localDormir;
    acessoAguaEnergia = d.acessoAguaEnergia;
    tipoQuarto = d.tipoQuarto;
    quartoCompartilhadoInfo = TextEditingController(
      text: d.quartoCompartilhadoCom ?? "",
    );
    acessoAreas = d.acessoAreasComuns;
    refeicoes = d.refeicoesOferecidas;
    maxIntercambistas = d.maxIntercambistas;
    temAnimais = d.temAnimais;
    detalhesAnimaisInfo = TextEditingController(text: d.detalhesAnimais ?? "");
    comodidades = List.from(d.comodidadesProximas);
    periodos = List.from(d.periodoHospedagem);
    moradoresController = TextEditingController(
      text: d.descricaoMoradores ?? "",
    );

    // Força a sincronização dos valores padrão com o painel pai assim que a tela abre!
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _atualizar();
    });
  }

  void _atualizar() {
    final novosDetalhes = DetalhesHospedagem(
      podeOferecerAcomodacao: podeOferecer,
      localDormir: localDormir,
      acessoAguaEnergia: acessoAguaEnergia,
      tipoQuarto: tipoQuarto,
      quartoCompartilhadoCom: tipoQuarto == 'Compartilhado'
          ? quartoCompartilhadoInfo.text
          : null,
      acessoAreasComuns: acessoAreas,
      refeicoesOferecidas: refeicoes,
      maxIntercambistas: maxIntercambistas,
      periodoHospedagem: periodos,
      temAnimais: temAnimais,
      detalhesAnimais: temAnimais ? detalhesAnimaisInfo.text : null,
      comodidadesProximas: comodidades,
      fotosUrl: widget.detalhesAtual?.fotosUrl ?? [],
      descricaoMoradores: moradoresController.text,
    );

    widget.onChanged(novosDetalhes);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Editor(
          controller: moradoresController,
          labelText: "Quem mora com você atualmente?",
          hintText: "Ex: Eu, meu marido e dois filhos...",
          keyboardType: TextInputType.multiline,
          onChanged: (_) => _atualizar(),
          isPassword: false,
          enabled: true,
        ),
        const SizedBox(height: 32),
        BooleanSelector(
          labelText: "Você pode oferecer acomodação gratuita?",
          value: podeOferecer,
          onChanged: (val) {
            setState(() => podeOferecer = val);
            _atualizar();
          },
        ),
        const SizedBox(height: 24),

        // NOVO
        BooleanSelector(
          labelText: "Pode oferecer acesso a água e energia de forma gratuita?",
          value: acessoAguaEnergia ?? true, // Default
          onChanged: (val) {
            setState(() => acessoAguaEnergia = val);
            _atualizar();
          },
        ),
        const SizedBox(height: 24),

        Selector(
          labelText: "Pode oferecer um local para que o intercambista durma?",
          value: localDormir,
          items: PerfilConstantes.localDormir,
          onChanged: (val) {
            setState(() => localDormir = val);
            _atualizar();
          },
        ),
        const SizedBox(height: 24),

        Selector(
          labelText: "Qual o tipo de quarto disponível?",
          value: tipoQuarto,
          items: PerfilConstantes.tipoQuarto,
          onChanged: (val) {
            setState(() => tipoQuarto = val!);
            _atualizar();
          },
        ),
        if (tipoQuarto == 'Compartilhado') ...[
          const SizedBox(height: 24),
          Editor(
            controller: quartoCompartilhadoInfo,
            labelText: "Com quem o quarto será compartilhado?",
            hintText: "Ex: Com meu irmão",
            onChanged: (_) => _atualizar(),
            isPassword: false,
            keyboardType: TextInputType.text,
            enabled: true,
          ),
        ],
        const SizedBox(height: 24),
        BooleanSelector(
          labelText: "O intercambista terá acesso livre às áreas comuns?",
          value: acessoAreas,
          onChanged: (val) {
            setState(() => acessoAreas = val);
            _atualizar();
          },
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Selector(
                labelText: "Refeições (dia)",
                value: refeicoes,
                items: PerfilConstantes.refeicoes,
                onChanged: (val) {
                  setState(() => refeicoes = val!);
                  _atualizar();
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Selector(
                labelText: "Máximo de hóspedes",
                value: maxIntercambistas,
                items: PerfilConstantes.maxIntercambistas,
                onChanged: (val) {
                  setState(() => maxIntercambistas = val!);
                  _atualizar();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        MultiSelectChips(
          labelText: "Por quanto tempo você pode hospedar?",
          allOptions: PerfilConstantes.periodosHospedagem,
          selectedOptions: periodos,
          onChanged: (l) {
            setState(() => periodos = l);
            _atualizar();
          },
        ),
        const SizedBox(height: 32),
        BooleanSelector(
          labelText: "Você tem animais de estimação?",
          value: temAnimais,
          onChanged: (val) {
            setState(() => temAnimais = val);
            _atualizar();
          },
        ),
        if (temAnimais) ...[
          const SizedBox(height: 24),
          Editor(
            controller: detalhesAnimaisInfo,
            labelText: "Quais animais e quantos?",
            hintText: "Ex: 2 gatos",
            onChanged: (_) => _atualizar(),
            isPassword: false,
            keyboardType: TextInputType.text,
            enabled: true,
          ),
        ],
        const SizedBox(height: 32),
        MultiSelectChips(
          labelText: "O que tem nas proximidades da sua casa?",
          allOptions: PerfilConstantes.comodidades,
          selectedOptions: comodidades,
          onChanged: (l) {
            setState(() => comodidades = l);
            _atualizar();
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
