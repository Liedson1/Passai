/// Definição única de uma rota popular / destaque do Passaí.
/// Centraliza a configuração usada tanto no Mobile quanto no Desktop.
class PopularRouteConfig {
  const PopularRouteConfig({
    required this.origem,
    required this.destino,
    this.via,
    required this.descricao,
    required this.precoPadrao,
    required this.fallbackId,
    required this.horarioSaida,
    this.paradasIntermediarias = const [],
  });

  final String origem;
  final String destino;
  final String? via;
  final String descricao;
  final double precoPadrao;
  final int fallbackId;
  final String horarioSaida;
  final List<String> paradasIntermediarias;

  String get precoFormatado =>
      'R\$ ${precoPadrao.toStringAsFixed(2).replaceAll('.', ',')}';
}

/// Rotas mais buscadas e estratégicas no Estado de Alagoas
const List<PopularRouteConfig> rotasPopularesDestaque = [
  PopularRouteConfig(
    origem: 'Arapiraca',
    destino: 'Maceió',
    via: 'via Litoral',
    descricao: 'Dois maiores polos do estado • via Litoral',
    precoPadrao: 36.00,
    fallbackId: 6,
    horarioSaida: '06:00',
  ),
  PopularRouteConfig(
    origem: 'Arapiraca',
    destino: 'Olho d\'Água das Flores',
    descricao: 'Importante ligação do Sertão',
    precoPadrao: 28.00,
    fallbackId: 54,
    horarioSaida: '06:30',
    paradasIntermediarias: ['Jaramataia', 'Jacaré dos Homens'],
  ),
  PopularRouteConfig(
    origem: 'Palmeira dos Índios',
    destino: 'Arapiraca',
    descricao: 'Cidades próximas, fluxo constante',
    precoPadrao: 10.00,
    fallbackId: 67,
    horarioSaida: '05:30',
  ),
  PopularRouteConfig(
    origem: 'Água Branca',
    destino: 'Delmiro Gouveia',
    via: 'via Lagoa das Pedras',
    descricao: 'Linha tradicional do Alto Sertão',
    precoPadrao: 12.00,
    fallbackId: 2,
    horarioSaida: '15:10',
  ),
  PopularRouteConfig(
    origem: 'Delmiro Gouveia',
    destino: 'Arapiraca',
    descricao: 'Ligação Alto Sertão ao Agreste',
    precoPadrao: 29.30,
    fallbackId: 26,
    horarioSaida: '13:40',
  ),
];
