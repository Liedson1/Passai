import 'package:passai/core/utils/duracao_estimativa.dart';
import 'package:passai/domain/entities/parada_itinerario.dart';

/// Entidade de domínio: Detalhes completos de uma viagem específica.
/// Contém as informações exibidas na tela de Detalhes da Viagem,
/// incluindo identificação do veículo, cooperativa, status, métricas e itinerário completo.
class DetalhesViagem {
  const DetalhesViagem({
    required this.codigo,
    required this.preco,
    required this.rota,
    required this.itinerario,
    this.via,
    this.horaSaida,
    this.chegadaPrevista,
    this.duracao,
    this.distancia,
    this.tipoLinha = 'Transporte Intermunicipal',
    this.cooperativa,
    this.veiculoNumero,
    this.veiculoModelo,
    this.veiculoPlaca,
    this.comodidades = const [],
    this.formasPagamento = const [],
    this.responsavelPagamento,
    this.status = 'No Horário',
    this.ultimaAtualizacao,
    this.aviso,
    this.alterado = false,
    this.horaOriginal,
    this.horaNova,
    this.vanOriginal,
    this.vanSubstituta,
    this.alteracaoMotivo,
    this.origem,
    this.destino,
    this.diasOperacao,
    this.seccionamentos,
  });

  /// Identificador da rota/linha (ex: linha ou id da rota)
  final String codigo;

  /// Tarifa da viagem formatada (ex: "R$ 28,00")
  final String preco;

  /// Nome da rota exibido (ex: "Arapiraca x Olho d'Água das Flores")
  final String rota;

  /// Paradas do itinerário em ordem cronológica (tabela paradas_rota)
  final List<ParadaItinerario> itinerario;

  /// Trajeto intermediário, quando houver (ex: "via Taquarana")
  final String? via;

  /// Horário de saída formatado (ex: "05:15" ou hora_nova da alteração)
  final String? horaSaida;

  /// Previsão de chegada estimada (quando calculada)
  final String? chegadaPrevista;

  /// Duração estimada calculada
  final String? duracao;

  /// Distância total do trajeto em km (tabela rotas.distancia_km)
  final String? distancia;

  /// Tipo de linha / transporte
  final String tipoLinha;

  /// Cooperativa ou associação (opcional, apenas quando cadastrada)
  final String? cooperativa;

  /// Identificação da van responsável (tabela alteracoes_horario.van_original)
  final String? veiculoNumero;

  /// Modelo do veículo (apenas se cadastrado)
  final String? veiculoModelo;

  /// Placa do veículo (apenas se cadastrada)
  final String? veiculoPlaca;

  /// Comodidades (apenas se cadastradas)
  final List<String> comodidades;

  /// Formas de pagamento aceitas
  final List<String> formasPagamento;

  /// Responsável pelo pagamento
  final String? responsavelPagamento;

  /// Status operacional atual ("No Horário" ou "Horário Alterado")
  final String status;

  /// Indicação temporal da última atualização
  final String? ultimaAtualizacao;

  /// Aviso de recomendação ao passageiro
  final String? aviso;

  /// Indica se a viagem sofreu alteração operacional no dia (RN06)
  final bool alterado;

  /// Horário original previsto (tabela alteracoes_horario.hora_original)
  final String? horaOriginal;

  /// Novo horário válido no dia (tabela alteracoes_horario.hora_nova)
  final String? horaNova;

  /// Van originalmente escalada (tabela alteracoes_horario.van_original)
  final String? vanOriginal;

  /// Motivo da alteração quando houver (tabela alteracoes_horario.motivo)
  final String? alteracaoMotivo;

  /// Van substituta quando houver alteração (tabela alteracoes_horario.van_substituta)
  final String? vanSubstituta;

  /// Cidade de origem
  final String? origem;

  /// Cidade de destino
  final String? destino;

  /// Dias de funcionamento (tabela rotas.dias_operacao)
  final String? diasOperacao;

  /// Cidades intermediárias (tabela rotas.seccionamentos)
  final String? seccionamentos;

  /// Primeira parada do itinerário (partida)
  ParadaItinerario? get partida =>
      itinerario.isNotEmpty ? itinerario.first : null;

  /// Última parada do itinerário (chegada)
  ParadaItinerario? get chegada =>
      itinerario.length > 1 ? itinerario.last : null;

  /// Cria uma instância a partir de um Map JSON
  factory DetalhesViagem.fromJson(Map<String, dynamic> json) {
    // Suporta payload direto, embrulhado em "viagem" ou "detalhesViagem"
    final data = json.containsKey('viagem') && json['viagem'] is Map<String, dynamic>
        ? json['viagem'] as Map<String, dynamic>
        : (json.containsKey('detalhesViagem') && json['detalhesViagem'] is Map<String, dynamic>
            ? json['detalhesViagem'] as Map<String, dynamic>
            : json);

    // Mapeamento dos blocos das tabelas do banco de dados
    final rotaMap = data['rota'] as Map<String, dynamic>? ??
        data['rotas'] as Map<String, dynamic>?;
    final horarioMap = data['horario'] as Map<String, dynamic>? ??
        data['horarios'] as Map<String, dynamic>?;
    final alteracaoMap = data['alteracao'] as Map<String, dynamic>? ??
        data['alteracoes_horario'] as Map<String, dynamic>?;

    // 1. Tabela rotas
    final rotaId = rotaMap?['id'] as int?;
    final linhaStr = rotaMap?['linha'] as String? ??
        data['linha'] as String? ??
        data['codigo'] as String? ??
        '';
    final origemStr = rotaMap?['origem'] as String? ?? data['origem'] as String?;
    final destinoStr = rotaMap?['destino'] as String? ?? data['destino'] as String?;
    final rotaNome = (origemStr != null && destinoStr != null)
        ? '$origemStr x $destinoStr'
        : linhaStr;

    final tarifaNum = (rotaMap?['tarifa'] as num?)?.toDouble();
    final precoStr = data['preco'] as String? ??
        (tarifaNum != null ? 'R\$ ${tarifaNum.toStringAsFixed(2).replaceAll('.', ',')}' : '');

    final distNum = rotaMap?['distancia_km'] as num?;
    final distanciaStr = data['distancia'] as String? ?? (distNum != null ? '$distNum km' : null);
    final diasOperacaoStr = rotaMap?['dias_operacao'] as String? ??
        data['dias_operacao'] as String? ??
        data['diasOperacao'] as String?;
    final seccionamentosStr = rotaMap?['seccionamentos'] as String? ??
        data['seccionamentos'] as String?;

    // 2. Tabela horarios e alteracoes_horario (RN03/RN05/RN06)
    final horaBase = horarioMap?['hora'] as String? ??
        data['hora'] as String? ??
        data['horaSaida'] as String?;
    final alteracaoAtiva = (alteracaoMap?['ativa'] as bool?) ??
        data['alterado'] as bool? ??
        false;
    final horaOriginal = alteracaoMap?['hora_original'] as String? ??
        data['horaOriginal'] as String?;
    final horaNova = alteracaoMap?['hora_nova'] as String? ??
        data['horaNova'] as String?;
    final horaEfetiva = alteracaoAtiva && horaNova != null && horaNova.isNotEmpty
        ? horaNova
        : (horaBase ?? '');

    // 3. Identificação do veículo (van_original e van_substituta - RN04)
    final vanOrig = alteracaoMap?['van_original'] as String? ??
        data['van_original'] as String? ??
        data['veiculoNumero'] as String?;
    final vanSubst = alteracaoMap?['van_substituta'] as String? ??
        data['van_substituta'] as String? ??
        data['vanSubstituta'] as String?;
    final motivo = alteracaoMap?['motivo'] as String? ??
        data['motivo'] as String? ??
        data['alteracaoMotivo'] as String?;

    final rawDuracao = data['duracao'] as String? ??
        rotaMap?['duracao'] as String? ??
        horarioMap?['duracao'] as String?;
    final duracaoPadronizada = DuracaoEstimativa.padronizar(rawDuracao) ??
        DuracaoEstimativa.estimar(distNum?.toInt());

    // 4. Tabela paradas_rota
    final rawParadas = (data['paradas'] as List?) ?? (data['itinerario'] as List?) ?? const [];
    final itinerarioList = rawParadas
        .whereType<Map<String, dynamic>>()
        .map(ParadaItinerario.fromJson)
        .toList();

    return DetalhesViagem(
      codigo: linhaStr.isNotEmpty ? linhaStr : (rotaId != null ? 'Linha $rotaId' : 'Passaí'),
      preco: precoStr,
      rota: rotaNome,
      itinerario: itinerarioList,
      origem: origemStr,
      destino: destinoStr,
      horaSaida: horaEfetiva,
      duracao: duracaoPadronizada,
      distancia: distanciaStr,
      diasOperacao: diasOperacaoStr,
      seccionamentos: seccionamentosStr,
      alterado: alteracaoAtiva,
      horaOriginal: horaOriginal,
      horaNova: horaNova,
      vanOriginal: vanOrig,
      vanSubstituta: vanSubst,
      veiculoNumero: vanSubst ?? vanOrig,
      alteracaoMotivo: motivo,
      status: alteracaoAtiva ? 'Horário Alterado' : 'No Horário',
      tipoLinha: 'Transporte Intermunicipal',
      aviso: data['aviso'] as String?,
    );
  }


  /// Converte a entidade para Map JSON alinhado com o banco
  Map<String, dynamic> toJson() => {
        'rota': {
          'linha': codigo,
          if (origem != null) 'origem': origem,
          if (destino != null) 'destino': destino,
          if (distancia != null) 'distancia_km': distancia,
          'tarifa': preco,
          if (diasOperacao != null) 'dias_operacao': diasOperacao,
          if (seccionamentos != null) 'seccionamentos': seccionamentos,
        },
        'horario': {
          if (horaSaida != null) 'hora': horaSaida,
        },
        'alteracao': {
          'ativa': alterado,
          if (horaOriginal != null) 'hora_original': horaOriginal,
          if (horaNova != null) 'hora_nova': horaNova,
          if (veiculoNumero != null) 'van_original': veiculoNumero,
          if (vanSubstituta != null) 'van_substituta': vanSubstituta,
          if (alteracaoMotivo != null) 'motivo': alteracaoMotivo,
        },
        'paradas': itinerario.map((p) => p.toJson()).toList(),
      };
}
