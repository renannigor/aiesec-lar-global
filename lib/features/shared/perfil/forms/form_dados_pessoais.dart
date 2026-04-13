import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:aiesec_lar_global/data/models/usuario/usuario.dart';
import 'package:aiesec_lar_global/core/widgets/editor.dart';
import 'package:aiesec_lar_global/core/widgets/selector.dart';
import '../perfil_constantes.dart';

// --- NOVOS IMPORTS PARA BUSCAR OS COMITÊS ---
import 'package:aiesec_lar_global/data/models/comite_local/comite_local.dart';
import 'package:aiesec_lar_global/data/services/comite_local_service.dart';

class FormDadosPessoais extends StatefulWidget {
  final Usuario usuario;
  final Function(Usuario usuarioAtualizado) onChanged;

  const FormDadosPessoais({
    super.key,
    required this.usuario,
    required this.onChanged,
  });

  @override
  State<FormDadosPessoais> createState() => _FormDadosPessoaisState();
}

class _FormDadosPessoaisState extends State<FormDadosPessoais> {
  late TextEditingController nomeController;
  late TextEditingController telefoneController;
  late TextEditingController profissaoController;
  late TextEditingController dataNascController;
  late TextEditingController pqHospedarController;

  String? sexo;
  String? civil;
  String? restricao;
  DateTime? dataNascimento;
  String? aiesecProxima;
  String? prefContato;
  String? comoConheceu;

  // --- VARIÁVEIS DO COMITÊ ---
  List<ComiteLocal> _listaComites = [];
  bool _carregandoComites = true;

  final _phoneMaskFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
  final _dateMaskFormatter = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void initState() {
    super.initState();
    nomeController = TextEditingController(text: widget.usuario.nome);
    telefoneController = TextEditingController(
      text: widget.usuario.telefone ?? "",
    );
    profissaoController = TextEditingController(
      text: widget.usuario.profissao ?? "",
    );
    pqHospedarController = TextEditingController(
      text: widget.usuario.porQueHospedar ?? "",
    );

    sexo = widget.usuario.sexo;
    civil = widget.usuario.estadoCivil;
    restricao = widget.usuario.restricaoAlimentarPropria;
    dataNascimento = widget.usuario.dataNascimento;

    aiesecProxima = widget.usuario.aiesecMaisProxima;
    prefContato = widget.usuario.comoPrefereSerContactado;
    comoConheceu = widget.usuario.comoConheceuAiesec;

    String dataFormatada = "";
    if (dataNascimento != null) {
      dataFormatada = DateFormat('dd/MM/yyyy').format(dataNascimento!);
    }
    dataNascController = TextEditingController(text: dataFormatada);

    // Busca os comitês assim que a tela abre
    _buscarComitesLocais();
  }

  // --- FUNÇÃO PARA CARREGAR COMITÊS ---
  Future<void> _buscarComitesLocais() async {
    try {
      final comites = await ComiteLocalService.instance
          .getComitesStream()
          .first;
      if (mounted) {
        setState(() {
          _listaComites = comites.where((c) => c.status == 'Ativo').toList()
            ..sort((a, b) => a.nome.compareTo(b.nome));
          _carregandoComites = false;
        });
      }
    } catch (e) {
      debugPrint("Erro ao carregar comitês no Perfil: $e");
      if (mounted) {
        setState(() => _carregandoComites = false);
      }
    }
  }

  void _atualizar() {
    DateTime? novaData;
    if (dataNascController.text.length == 10) {
      try {
        novaData = DateFormat('dd/MM/yyyy').parse(dataNascController.text);
      } catch (e) {
        novaData = null;
      }
    } else {
      novaData = dataNascController.text.isEmpty ? null : dataNascimento;
    }

    widget.onChanged(
      widget.usuario.copyWith(
        nome: nomeController.text,
        telefone: telefoneController.text,
        profissao: profissaoController.text,
        estadoCivil: civil,
        sexo: sexo,
        restricaoAlimentarPropria: restricao,
        dataNascimento: novaData,
        aiesecMaisProxima: aiesecProxima,
        comoPrefereSerContactado: prefContato,
        comoConheceuAiesec: comoConheceu,
        porQueHospedar: pqHospedarController.text,
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dataNascimento ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        dataNascimento = picked;
        dataNascController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
      _atualizar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Editor(
          controller: nomeController,
          labelText: "Nome Completo",
          hintText: "Seu nome completo",
          keyboardType: TextInputType.name,
          onChanged: (_) => _atualizar(),
          isPassword: false,
          enabled: true,
        ),
        const SizedBox(height: 24),
        Editor(
          controller: telefoneController,
          labelText: "Telefone de Contato",
          hintText: "(99) 99999-9999",
          keyboardType: TextInputType.phone,
          inputFormatters: [_phoneMaskFormatter],
          onChanged: (_) => _atualizar(),
          isPassword: false,
          enabled: true,
        ),
        const SizedBox(height: 24),
        Editor(
          controller: profissaoController,
          labelText: "Qual sua profissão?",
          hintText: "Ex: Professor, Engenheiro...",
          keyboardType: TextInputType.text,
          onChanged: (_) => _atualizar(),
          isPassword: false,
          enabled: true,
        ),
        const SizedBox(height: 24),
        Editor(
          controller: dataNascController,
          labelText: "Data de Nascimento",
          hintText: "dd/mm/aaaa",
          keyboardType: TextInputType.number,
          inputFormatters: [_dateMaskFormatter],
          onChanged: (_) => _atualizar(),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _pickDate,
          ),
          isPassword: false,
          enabled: true,
        ),
        const SizedBox(height: 24),
        Editor(
          controller: pqHospedarController,
          labelText: "Por que gostaria de fazer parte do Lar Global?",
          hintText: "Explique brevemente seus motivos...",
          keyboardType: TextInputType.multiline,
          onChanged: (_) => _atualizar(),
          isPassword: false,
          enabled: true,
        ),
        const SizedBox(height: 24),
        _carregandoComites
            ? const Center(child: CircularProgressIndicator())
            : Selector<String>(
                labelText: "AIESEC mais próxima",
                value: _listaComites.map((c) => c.nome).contains(aiesecProxima)
                    ? aiesecProxima
                    : null,
                items: _listaComites.map((c) => c.nome).toList(),
                onChanged: (val) {
                  setState(() => aiesecProxima = val);
                  _atualizar();
                },
              ),
        const SizedBox(height: 24),

        Selector(
          labelText: "Estado Civil",
          value: civil,
          items: PerfilConstantes.estadoCivil,
          onChanged: (val) {
            setState(() => civil = val);
            _atualizar();
          },
        ),
        const SizedBox(height: 24),
        Selector(
          labelText: "Gênero",
          value: sexo,
          items: PerfilConstantes.sexo,
          onChanged: (val) {
            setState(() => sexo = val);
            _atualizar();
          },
        ),
        const SizedBox(height: 24),
        Selector(
          labelText: "Você possui alguma restrição alimentar?",
          value: restricao,
          items: PerfilConstantes.restricaoAlimentar,
          onChanged: (val) {
            setState(() => restricao = val);
            _atualizar();
          },
        ),
        const SizedBox(height: 24),
        Selector(
          labelText: "Como prefere ser contactado?",
          value: prefContato,
          items: PerfilConstantes.formasContato,
          onChanged: (val) {
            setState(() => prefContato = val);
            _atualizar();
          },
        ),
        const SizedBox(height: 24),
        Selector(
          labelText: "Como conheceu a AIESEC?",
          value: comoConheceu,
          items: PerfilConstantes.comoConheceu,
          onChanged: (val) {
            setState(() => comoConheceu = val);
            _atualizar();
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
