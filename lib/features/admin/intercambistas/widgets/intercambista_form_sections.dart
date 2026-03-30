import 'package:flutter/material.dart';
import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/core/widgets/editor.dart';

// --- Header da Seção ---
class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

// --- Seção: Perfil do Voluntário ---
class ProfileSection extends StatelessWidget {
  final TextEditingController formacaoCtrl;
  final TextEditingController idiomasCtrl;
  final TextEditingController interessesCtrl;

  const ProfileSection({
    super.key,
    required this.formacaoCtrl,
    required this.idiomasCtrl,
    required this.interessesCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: "Perfil do Voluntário (Opcional)"),
        Editor(
          controller: formacaoCtrl,
          labelText: "Formação Acadêmica",
          isPassword: false,
          keyboardType: TextInputType.text,
          enabled: true,
        ),
        const SizedBox(height: 16),
        Editor(
          controller: idiomasCtrl,
          labelText: "Idiomas (separe por vírgula)",
          hintText: "Ex: Inglês, Espanhol",
          isPassword: false,
          keyboardType: TextInputType.text,
          enabled: true,
        ),
        const SizedBox(height: 16),
        Editor(
          controller: interessesCtrl,
          labelText: "Interesses (separe por vírgula)",
          hintText: "Ex: Futebol, Música, Leitura",
          isPassword: false,
          keyboardType: TextInputType.text,
          enabled: true,
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

// --- Seção: Descrições ---
class DescriptionSection extends StatelessWidget {
  final TextEditingController sobreMimCtrl;
  final TextEditingController hobbiesCtrl;
  final TextEditingController motivacaoCtrl;

  const DescriptionSection({
    super.key,
    required this.sobreMimCtrl,
    required this.hobbiesCtrl,
    required this.motivacaoCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: "Descrições (Opcional)"),
        Editor(
          controller: sobreMimCtrl,
          labelText: "Sobre Mim",
          isPassword: false,
          keyboardType: TextInputType.multiline,
          enabled: true,
        ),
        const SizedBox(height: 16),
        Editor(
          controller: hobbiesCtrl,
          labelText: "Detalhes sobre Hobbies",
          isPassword: false,
          keyboardType: TextInputType.multiline,
          enabled: true,
        ),
        const SizedBox(height: 16),
        Editor(
          controller: motivacaoCtrl,
          labelText: "Motivação",
          isPassword: false,
          keyboardType: TextInputType.multiline,
          enabled: true,
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

// --- Seção: Informações Pessoais ---
class PersonalInfoSection extends StatelessWidget {
  final bool isFumante;
  final ValueChanged<bool?> onFumanteChanged;
  final TextEditingController alergiasCtrl;
  final TextEditingController restricoesCtrl;

  const PersonalInfoSection({
    super.key,
    required this.isFumante,
    required this.onFumanteChanged,
    required this.alergiasCtrl,
    required this.restricoesCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: "Informações Pessoais (Opcional)"),
        CheckboxListTile(
          title: const Text("Fumante"),
          value: isFumante,
          onChanged: onFumanteChanged,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        Editor(
          controller: alergiasCtrl,
          labelText: "Alergias",
          isPassword: false,
          keyboardType: TextInputType.text,
          enabled: true,
        ),
        const SizedBox(height: 16),
        Editor(
          controller: restricoesCtrl,
          labelText: "Restrições Alimentares/Outras",
          isPassword: false,
          keyboardType: TextInputType.text,
          enabled: true,
        ),
      ],
    );
  }
}
