enum PodioAppType {
  epsIcx('EPs ICX'),
  opensIcx('Opens ICX'),
  larGlobal('Lar Global'),
  nps('NPS Lar Global');

  final String nomePodio;
  const PodioAppType(this.nomePodio);

  // Transforma a string do Firebase no Enum de forma segura
  static PodioAppType? fromString(String? valor) {
    if (valor == 'EPs ICX') return PodioAppType.epsIcx;
    if (valor == 'Opens ICX') return PodioAppType.opensIcx;
    if (valor == 'Lar Global') return PodioAppType.larGlobal;
    if (valor == 'NPS Lar Global') return PodioAppType.nps;
    return null;
  }
}

class PodioCredentialsModel {
  final String appId;
  final String appToken;
  final String clientId;
  final String clientSecret;
  final PodioAppType? appType;

  PodioCredentialsModel({
    required this.appId,
    required this.appToken,
    required this.clientId,
    required this.clientSecret,
    this.appType,
  });

  factory PodioCredentialsModel.fromFirestore(Map<String, dynamic> map) {
    return PodioCredentialsModel(
      appId: map['app_id']?.toString() ?? '',
      appToken: map['app_token']?.toString() ?? '',
      clientId: map['client_id']?.toString() ?? '',
      clientSecret: map['client_secret']?.toString() ?? '',
      appType: PodioAppType.fromString(map['app']?.toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'app_id': appId,
      'app_token': appToken,
      'client_id': clientId,
      'client_secret': clientSecret,
      if (appType != null) 'app': appType!.nomePodio,
    };
  }
}
