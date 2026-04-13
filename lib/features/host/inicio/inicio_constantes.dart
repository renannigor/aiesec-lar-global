import 'package:aiesec_lar_global/data/models/area_filtro.dart';

class InicioConstantes {
  // Evita instanciação
  InicioConstantes._();

  static const List<String> faixasEtarias = [
    '18 - 21 anos',
    '22 - 25 anos',
    '26 - 30 anos',
  ];

  static const List<String> idiomas = [
    'Alemão',
    'Árabe',
    'Espanhol',
    'Francês',
    'Inglês',
    'Italiano',
    'Japonês',
    'Mandarim',
    'Português',
    'Russo',
  ];

  static const List<String> status = ['Disponível', 'Indisponível'];

  static const List<String> filtroAcomodacao = ['Sim', 'Não'];

  // Definição das áreas traduzidas para o Host
  static final List<AreaFiltro> opcoesAreas = [
    AreaFiltro(label: "Trabalho Voluntário", value: "iGV"),
    AreaFiltro(label: "Estágio Profissional (Empresas)", value: "iGTa"),
    AreaFiltro(label: "Estágio Profissional (Ensino/Professor)", value: "iGTe"),
  ];
}
