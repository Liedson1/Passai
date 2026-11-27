import 'package:latlong2/latlong.dart';
import 'package:passai/core/utils/text_normalizer.dart';

/// Registro canônico de coordenadas geográficas oficiais (IBGE / OpenStreetMap)
/// para municípios e localidades do estado de Alagoas.
///
/// Garante precisão máxima na fixação dos pinos no mapa urbano de cada cidade,
/// com tolerância zero a deslocamentos causados por dados de terceiros ou nulos.
class CoordenadasCidades {
  CoordenadasCidades._();

  /// Retorna as coordenadas oficiais da cidade/localidade se conhecida.
  static LatLng? obter(String? nomeCidade) {
    if (nomeCidade == null || nomeCidade.trim().isEmpty) return null;
    final chave = TextNormalizer.normalizar(nomeCidade);
    return _coordenadas[chave];
  }

  static final Map<String, LatLng> _coordenadas = {
    'anadia': const LatLng(-9.68302, -36.30527), // Anadia
    'arapiraca': const LatLng(-9.7495158, -36.6666349), // Arapiraca (Ponto das vans — Rua Santos Dumont / Baixão)
    'batalha': const LatLng(-9.6734, -37.1265), // Batalha
    'boca da mata': const LatLng(-9.64521, -36.21167), // Boca da Mata
    'bom jardim': const LatLng(-9.765, -36.5821), // Bom Jardim
    'bonsucesso': const LatLng(-9.5683, -37.1215), // Bonsucesso
    'botafogo': const LatLng(-10.1687, -36.314), // Botafogo
    'cacimbinhas': const LatLng(-9.40121, -36.99108), // Cacimbinhas
    'canapi': const LatLng(-9.11736, -37.60117), // Canapi
    'coruripe': const LatLng(-10.1256, -36.1756), // Coruripe
    'craibas': const LatLng(-9.6168, -36.76846), // Craíbas
    'delmiro gouveia': const LatLng(-9.38412, -37.99776), // Delmiro Gouveia
    'dois riachos': const LatLng(-9.38465, -37.0965), // Dois Riachos
    'feira grande': const LatLng(-9.8956, -36.6787), // Feira Grande
    'folha miuda': const LatLng(-9.7033, -36.7952), // Folha Miúda
    'girau do ponciano': const LatLng(-9.88404, -36.83159), // Girau do Ponciano
    'igaci': const LatLng(-9.5379, -36.6318), // Igaci
    'igreja nova': const LatLng(-10.1267, -36.6582), // Igreja Nova
    'inhapi': const LatLng(-9.22209, -37.74807), // Inhapi
    'jacare dos homens': const LatLng(-9.63548, -37.20475), // Jacaré dos Homens (Rua Monsenhor Freitas Machado — via de travessia)
    'jacare dos homens (entrada)': const LatLng(-9.63098, -37.20742), // Acesso Oeste AL-220
    'jacare dos homens (saida)': const LatLng(-9.63350, -37.20050), // Acesso Leste AL-220
    'jaramataia': const LatLng(-9.65769, -37.00450), // Jaramataia (Rua do Comércio — via de travessia contínua sem desvios)
    'jaramataia (acesso oeste)': const LatLng(-9.65091, -37.01000), // Acesso Oeste AL-220
    'jaramataia (al220 oeste)': const LatLng(-9.65057, -37.01008), // AL-220 sentido Batalha/Jacaré
    'jaramataia (acesso leste)': const LatLng(-9.64835, -36.99897), // Acesso Leste AL-220
    'junqueiro': const LatLng(-9.9298, -36.2023), // Junqueiro
    'lagoa da canoa': const LatLng(-9.8294, -36.73956), // Lagoa da Canoa
    'lagoa das pedras': const LatLng(-9.32, -37.97), // Lagoa das Pedras
    'limoeiro de anadia': const LatLng(-9.74539, -36.45951), // Limoeiro de Anadia
    'maceio': const LatLng(-9.64768, -35.73393), // Maceió
    'major izidoro': const LatLng(-9.53266, -36.9862), // Major Izidoro
    'maravilha': const LatLng(-9.23045, -37.35242), // Maravilha
    'maribondo': const LatLng(-9.5798, -36.3065), // Maribondo
    'mata grande': const LatLng(-9.11824, -37.7323), // Mata Grande
    'minador do negrao': const LatLng(-9.3124, -36.8696), // Minador do Negrão
    'monteiropolis': const LatLng(-9.60257, -37.24617), // Monteirópolis
    'olho dagua grande': const LatLng(-10.0561, -36.8135), // Olho d'Água Grande
    'olho dagua das flores': const LatLng(-9.536204, -37.293985), // Olho d'Água das Flores (Ponto das vans — Rua do Comércio)
    'olho dagua do casado': const LatLng(-9.50208, -37.83245), // Olho d'Água do Casado
    'olivenca': const LatLng(-9.51906, -37.18933), // Olivença
    'ouro branco': const LatLng(-9.16227, -37.35829), // Ouro Branco
    'palestina': const LatLng(-9.6721, -37.3293), // Palestina
    'palmeira dos indios': const LatLng(-9.4076, -36.6324), // Palmeira dos Índios
    'papa farinha': const LatLng(-9.72, -36.55), // Papa Farinha
    'pariconha': const LatLng(-9.25401, -38.00392), // Pariconha
    'paulo jacinto': const LatLng(-9.36792, -36.36724), // Paulo Jacinto
    'penedo': const LatLng(-10.2872, -36.5819), // Penedo
    'piacabucu': const LatLng(-10.40669, -36.43365), // Piaçabuçu
    'pindorama': const LatLng(-10.1504, -36.3317), // Pindorama
    'piranhas': const LatLng(-9.6256, -37.7567), // Piranhas
    'porto real do colegio': const LatLng(-10.1868, -36.8357), // Porto Real do Colégio
    'poco das trincheiras': const LatLng(-9.3063, -37.2855), // Poço das Trincheiras
    'pao de acucar': const LatLng(-9.7497, -37.433), // Pão de Açúcar
    'pe leve': const LatLng(-9.7597, -36.5566), // Pé Leve
    'quebrangulo': const LatLng(-9.32176, -36.47358), // Quebrangulo
    'rio largo': const LatLng(-9.4797, -35.845), // Rio Largo
    'santa cruz do deserto': const LatLng(-9.1443, -37.8357), // Santa Cruz do Deserto
    'santa terezinha': const LatLng(-9.6784, -37.321), // Santa Terezinha
    'santana do ipanema': const LatLng(-9.36999, -37.24802), // Santana do Ipanema
    'senador rui palmeira': const LatLng(-9.46987, -37.45761), // Senador Rui Palmeira
    'sao bras': const LatLng(-10.12585, -36.89815), // São Brás
    'sao jose da tapera': const LatLng(-9.55843, -37.38189), // São José da Tapera
    'sao miguel dos campos': const LatLng(-9.7811, -36.0911), // São Miguel dos Campos
    'sao sebastiao': const LatLng(-9.93151, -36.54392), // São Sebastião
    'tanque darca': const LatLng(-9.53482, -36.43146), // Tanque d'Arca
    'taquarana': const LatLng(-9.61259, -36.51019), // Taquarana
    'teotonio vilela': const LatLng(-9.90627, -36.35713), // Teotônio Vilela
    'traipu': const LatLng(-9.96758, -37.00154), // Traipu
    'vicosa': const LatLng(-9.3728, -36.24326), // Viçosa
    'agua branca': const LatLng(-9.26136, -37.93611), // Água Branca
  };
}
