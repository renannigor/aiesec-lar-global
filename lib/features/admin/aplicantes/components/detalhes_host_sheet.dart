import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/data/models/usuario/usuario.dart';

class DetalhesHostSheet extends StatelessWidget {
  final Usuario host;

  const DetalhesHostSheet({super.key, required this.host});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- CABEÇALHO ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Perfil Completo do Host",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  splashRadius: 24,
                ),
              ],
            ),
          ),

          // --- CORPO ROLÁVEL ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. DADOS BÁSICOS (CABEÇALHO DO PERFIL) ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.1,
                        ),
                        backgroundImage: host.fotoPerfilUrl.isNotEmpty
                            ? NetworkImage(host.fotoPerfilUrl)
                            : null,
                        child: host.fotoPerfilUrl.isEmpty
                            ? Text(
                                host.nome.isNotEmpty
                                    ? host.nome[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  fontSize: 32,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              host.nome,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Conta criada em: ${DateFormat('dd/MM/yyyy').format(host.criadoEm)}",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Indicador visual de Progresso
                            Row(
                              children: [
                                Text(
                                  "Perfil preenchido: ",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  "${(host.progressoPreenchimento * 100).toInt()}%",
                                  style: TextStyle(
                                    color: host.isPerfilCompleto
                                        ? Colors.green
                                        : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // --- 2. INFORMAÇÕES PESSOAIS & CRM ---
                  _buildExpandableSection(
                    title: "Informações Pessoais & CRM",
                    icon: Icons.person_outline,
                    initiallyExpanded: true,
                    children: [
                      _buildInfoRow(
                        Icons.cake_outlined,
                        "Nascimento / Idade",
                        host.dataNascimento != null
                            ? "${DateFormat('dd/MM/yyyy').format(host.dataNascimento!)} (${_calcularIdade(host.dataNascimento!)} anos)"
                            : "Não informado",
                      ),
                      _buildInfoRow(
                        Icons.wc_outlined,
                        "Sexo",
                        host.sexo ?? "Não informado",
                      ),
                      _buildInfoRow(
                        Icons.family_restroom_outlined,
                        "Estado Civil",
                        host.estadoCivil ?? "Não informado",
                      ),
                      _buildInfoRow(
                        Icons.work_outline,
                        "Profissão",
                        host.profissao ?? "Não informado",
                      ),
                      _buildInfoRow(
                        Icons.restaurant_outlined,
                        "Restrição Alimentar do Host",
                        host.restricaoAlimentarPropria ?? "Nenhuma",
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(Icons.email_outlined, "E-mail", host.email),
                      _buildInfoRow(
                        Icons.phone_outlined,
                        "Telefone / WhatsApp",
                        host.telefone ?? "Não informado",
                      ),
                      _buildInfoRow(
                        Icons.chat_bubble_outline,
                        "Prefe ser contactado via",
                        host.comoPrefereSerContactado ?? "Não informado",
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        Icons.map_outlined,
                        "AIESEC mais próxima",
                        host.aiesecMaisProxima ?? "Não informado",
                      ),
                      _buildInfoRow(
                        Icons.campaign_outlined,
                        "Como conheceu a AIESEC?",
                        host.comoConheceuAiesec ?? "Não informado",
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- 3. ENDEREÇO ---
                  _buildExpandableSection(
                    title: "Endereço da Hospedagem",
                    icon: Icons.location_on_outlined,
                    children: [
                      if (host.endereco == null)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "Endereço ainda não preenchido.",
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      else ...[
                        _buildInfoRow(
                          Icons.signpost_outlined,
                          "Logradouro",
                          "${host.endereco!.logradouro}, ${host.endereco!.numero}",
                        ),
                        if (host.endereco!.complemento != null &&
                            host.endereco!.complemento!.isNotEmpty)
                          _buildInfoRow(
                            Icons.info_outline,
                            "Complemento",
                            host.endereco!.complemento!,
                          ),
                        _buildInfoRow(
                          Icons.location_city_outlined,
                          "Bairro e Localidade",
                          "${host.endereco!.bairro} | ${host.endereco!.cidade} - ${host.endereco!.estado}",
                        ),
                        _buildInfoRow(
                          Icons.markunread_mailbox_outlined,
                          "CEP",
                          host.endereco!.cep,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- 4. DETALHES DA CASA E ACOMODAÇÃO ---
                  _buildExpandableSection(
                    title: "Detalhes da Hospedagem & Rotina",
                    icon: Icons.home_outlined,
                    children: [
                      if (host.detalhesHospedagem == null)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "Detalhes da acomodação ainda não preenchidos.",
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      else ...[
                        _buildInfoRow(
                          Icons.bed_outlined,
                          "Tipo de Quarto",
                          host.detalhesHospedagem!.tipoQuarto,
                        ),
                        if (host.detalhesHospedagem!.tipoQuarto.toLowerCase() ==
                                'compartilhado' &&
                            host.detalhesHospedagem!.quartoCompartilhadoCom !=
                                null)
                          _buildInfoRow(
                            Icons.people_outline,
                            "Compartilhado com",
                            host.detalhesHospedagem!.quartoCompartilhadoCom!,
                          ),
                        if (host.detalhesHospedagem!.localDormir != null)
                          _buildInfoRow(
                            Icons.hotel_outlined,
                            "Local de dormir",
                            host.detalhesHospedagem!.localDormir!,
                          ),
                        _buildInfoRow(
                          Icons.kitchen_outlined,
                          "Acesso às áreas comuns?",
                          host.detalhesHospedagem!.acessoAreasComuns
                              ? "Sim"
                              : "Não",
                        ),
                        _buildInfoRow(
                          Icons.fastfood_outlined,
                          "Refeições Oferecidas",
                          host.detalhesHospedagem!.refeicoesOferecidas,
                        ),
                        _buildInfoRow(
                          Icons.group_add_outlined,
                          "Pode receber até",
                          "${host.detalhesHospedagem!.maxIntercambistas} intercambista(s)",
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          Icons.pets_outlined,
                          "Animais de Estimação",
                          host.detalhesHospedagem!.temAnimais
                              ? "Sim, possui animais."
                              : "Não possui animais.",
                        ),
                        if (host.detalhesHospedagem!.temAnimais &&
                            host.detalhesHospedagem!.detalhesAnimais != null)
                          _buildInfoRow(
                            Icons.info_outline,
                            "Detalhes dos Animais",
                            host.detalhesHospedagem!.detalhesAnimais!,
                          ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          Icons.family_restroom_outlined,
                          "Quem mora na residência?",
                          host.detalhesHospedagem!.descricaoMoradores ??
                              "Não informado",
                        ),
                        _buildInfoRow(
                          Icons.directions_bus_outlined,
                          "Comodidades próximas (Transporte/Mercado)",
                          host.detalhesHospedagem!.comodidadesProximas.join(
                            ', ',
                          ),
                        ),
                        _buildInfoRow(
                          Icons.calendar_month_outlined,
                          "Períodos que pode hospedar",
                          host.detalhesHospedagem!.periodoHospedagem.join(', '),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- 5. EXPECTATIVAS E PREFERÊNCIAS DO HOST ---
                  _buildExpandableSection(
                    title: "Preferências e Expectativas",
                    icon: Icons.favorite_border_outlined,
                    children: [
                      // Dados que vêm direto do CRM (Usuário)
                      _buildInfoRow(
                        Icons.psychology_outlined,
                        "Por que quer ser Host?",
                        host.porQueHospedar ?? "Não informado",
                      ),
                      _buildInfoRow(
                        Icons.lightbulb_outline,
                        "Expectativas com o Intercambista",
                        host.expectativasIntercambista ?? "Não informado",
                      ),
                      const Divider(height: 24),

                      // Dados do objeto PreferenciasHospedagem
                      if (host.preferenciasHospedagem == null)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "Preferências restritivas ainda não preenchidas.",
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      else ...[
                        _buildInfoRow(
                          Icons.smoke_free_outlined,
                          "Aceita Fumantes?",
                          host.preferenciasHospedagem!.restricaoFumantes
                              ? "Não (Apenas não fumantes)"
                              : "Sim",
                        ),
                        _buildInfoRow(
                          Icons.no_meals_outlined,
                          "Aceita EPs com restrição alimentar?",
                          host.preferenciasHospedagem!.aceitaRestricaoAlimentar
                              .join(', '),
                        ),
                        _buildInfoRow(
                          Icons.wc_outlined,
                          "Preferência de Sexo do EP",
                          host.preferenciasHospedagem!.preferenciaSexo,
                        ),
                        _buildInfoRow(
                          Icons.translate_outlined,
                          "Idiomas preferenciais",
                          host.preferenciasHospedagem!.preferenciaIdiomas.join(
                            ', ',
                          ),
                        ),
                        if (host.preferenciasHospedagem!.outrosIdiomas !=
                                null &&
                            host
                                .preferenciasHospedagem!
                                .outrosIdiomas!
                                .isNotEmpty)
                          _buildInfoRow(
                            Icons.add_comment_outlined,
                            "Outros Idiomas",
                            host.preferenciasHospedagem!.outrosIdiomas!,
                          ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES PARA PADRONIZAR O DESIGN ---

  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
    bool initiallyExpanded = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        iconColor: AppColors.primary,
        collapsedIconColor: Colors.grey.shade500,
        leading: Icon(icon, color: const Color(0xFF6B7280)),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        children: [
          Container(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 20,
              top: 8,
            ),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade500),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _calcularIdade(DateTime dataNascimento) {
    final hoje = DateTime.now();
    int idade = hoje.year - dataNascimento.year;
    if (hoje.month < dataNascimento.month ||
        (hoje.month == dataNascimento.month && hoje.day < dataNascimento.day)) {
      idade--;
    }
    return idade;
  }
}
