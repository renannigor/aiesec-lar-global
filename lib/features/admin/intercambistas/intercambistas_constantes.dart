class AppConstants {
  // Construtor privado para evitar que a classe seja instanciada por engano
  AppConstants._();

  // --- STATUS DO PODIO (EXPA) ---
  // Usado nos formulários de edição
  static const List<String> statusPodio = [
    'Approved',
    'Realized',
    'Finished',
    'Completed',
  ];

  // Usado nos filtros (inclui a opção 'Todos')
  static const List<String> statusFiltro = [
    'Todos',
    ...statusPodio, // Usa o spread operator para puxar a lista de cima!
  ];

  // --- FILTROS GENÉRICOS ---
  static const List<String> filtroSimNao = [
    'Todos',
    'Sim',
    'Não',
  ];

  // --- TABELA PAGINADA ---
  static const List<int> tableRowsOptions = [10, 20, 50];
}