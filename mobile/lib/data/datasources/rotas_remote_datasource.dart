import 'dart:async';
import 'dart:io';

import 'package:passai/core/constants/app_constants.dart';
import 'package:passai/core/errors/exceptions.dart';
import 'package:passai/core/network/supabase_client.dart';
import 'package:passai/data/models/horario_model.dart';
import 'package:passai/data/models/parada_rota_model.dart';
import 'package:passai/data/models/rota_model.dart';


/// Responsável por todas as queries ao Supabase.
/// Não contém lógica de negócio — apenas acesso remoto a dados.
/// Requer conexão ativa com a internet para funcionar.
class RotasRemoteDatasource {
  static const Duration _timeout = Duration(seconds: 10);

  /// Trata exceções de rede e converte para [NetworkException] ou [ServerException].
  Exception _handleError(Object error) {
    // Verifica tipo explícito antes de recorrer ao string matching
    if (error is SocketException || error is TimeoutException) {
      return const NetworkException(
        'Sem conexão com a internet. O Passaí precisa de conexão ativa para consultar os horários em tempo real.',
      );
    }
    // Fallback: erros de rede que chegam como mensagens genéricas
    final msg = error.toString().toLowerCase();
    const networkKeywords = [
      'socket',
      'failed host lookup',
      'network is unreachable',
      'connection refused',
      'connection reset',
      'timed out',
      'clientexception',
    ];
    if (networkKeywords.any(msg.contains)) {
      return const NetworkException(
        'Sem conexão com a internet. O Passaí precisa de conexão ativa para consultar os horários em tempo real.',
      );
    }
    return ServerException('Erro ao carregar dados do servidor: $error');
  }

  /// Busca todas as rotas ativas com nomes das cidades de origem e destino.
  Future<List<RotaModel>> fetchTodasAsRotas() async {
    try {
      final response = await supabase
          .from('rotas')
          .select('''
            id,
            linha,
            distancia_km,
            tarifa,
            seccionamentos,
            origem:cidades!rotas_origem_id_fkey(nome),
            destino:cidades!rotas_destino_id_fkey(nome)
          ''')
          .eq('ativa', true)
          .not(
            'id',
            'in',
            '(${AppConstants.rotasSemHorarioIds.join(',')})',
          )
          .timeout(_timeout);

      final rotas = (response as List)
          .map((json) => RotaModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return rotas;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Busca cidades que possuem rotas ativas associadas (origem ou destino).
  /// Garante que apenas cidades com vans operacionais apareçam na busca (RN02),
  /// eliminando cidades não associadas ou paradas intermediárias sem rota definida.
  Future<List<String>> fetchCidades({String? termo}) async {
    try {
      final rotas = await fetchTodasAsRotas();
      final cidadesSet = <String>{};
      for (final r in rotas) {
        final origem = r.origem.trim();
        final destino = r.destino.trim();
        if (origem.isNotEmpty) cidadesSet.add(origem);
        if (destino.isNotEmpty) cidadesSet.add(destino);
      }

      var cidades = cidadesSet.toList()..sort((a, b) => a.compareTo(b));

      if (termo != null && termo.trim().isNotEmpty) {
        final termoNorm = _normalizar(termo.trim());
        cidades = cidades
            .where((c) => _normalizar(c).contains(termoNorm))
            .toList();
      }

      return cidades;
    } catch (e) {
      throw _handleError(e);
    }
  }

  static String _normalizar(String str) {
    return str
        .toLowerCase()
        .replaceAll(RegExp(r'[àáâãäå]'), 'a')
        .replaceAll(RegExp(r'[èéêë]'), 'e')
        .replaceAll(RegExp(r'[ìíîï]'), 'i')
        .replaceAll(RegExp(r'[òóôõö]'), 'o')
        .replaceAll(RegExp(r'[ùúûü]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c');
  }

  /// Busca horários de uma rota e sentido, incluindo alteração ativa do dia.
  Future<List<HorarioModel>> fetchHorarios({
    required int rotaId,
    required String sentido,
  }) async {
    try {
      final response = await supabase
          .from('horarios')
          .select('''
            id,
            hora,
            sentido,
            dias_funcionamento,
            rotas!horarios_rota_id_fkey(
              id,
              linha,
              distancia_km,
              tarifa,
              seccionamentos,
              origem:cidades!rotas_origem_id_fkey(nome),
              destino:cidades!rotas_destino_id_fkey(nome)
            ),
            alteracoes_horario(
              id,
              hora_original,
              hora_nova,
              van_original,
              van_substituta,
              motivo,
              data_alteracao,
              ativa
            )
          ''')
          .eq('rota_id', rotaId)
          .eq('sentido', sentido)
          .order('hora', ascending: true)
          .timeout(_timeout);

      final horarios = (response as List)
          .map((json) => HorarioModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return horarios;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Busca horários para uma data específica (tela de resultados).
  /// Filtra os horários que operam no dia da semana selecionado (RN10).
  Future<List<HorarioModel>> fetchHorariosPorData({
    required int rotaId,
    required String sentido,
    required DateTime data,
  }) async {
    final todosHorarios = await fetchHorarios(rotaId: rotaId, sentido: sentido);
    return todosHorarios.where((h) => h.toEntity().operaNoDia(data)).toList();
  }

  /// Busca as paradas do itinerário de uma rota/sentido, ordenadas por [ordem].
  /// Retorna lista vazia quando a rota não possui paradas cadastradas,
  /// permitindo fallback gracioso na camada de apresentação.
  Future<List<ParadaRotaModel>> fetchParadasRota({
    required int rotaId,
    required String sentido,
  }) async {
    try {
      final response = await supabase
          .from('paradas_rota')
          .select('id, rota_id, sentido, ordem, cidade, descricao')
          .eq('rota_id', rotaId)
          .eq('sentido', sentido)
          .order('ordem', ascending: true)
          .timeout(_timeout);

      return (response as List)
          .map((json) => ParadaRotaModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }
}
