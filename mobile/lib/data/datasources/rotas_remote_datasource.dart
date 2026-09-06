import 'dart:async';
import 'dart:io';

import 'package:passai/core/errors/exceptions.dart';
import 'package:passai/core/network/supabase_client.dart';
import 'package:passai/data/models/horario_model.dart';
import 'package:passai/data/models/rota_model.dart';

/// Responsável por todas as queries ao Supabase.
/// Não contém lógica de negócio — apenas acesso remoto a dados.
/// Requer conexão ativa com a internet para funcionar.
class RotasRemoteDatasource {
  static const Duration _timeout = Duration(seconds: 10);

  /// Trata exceções de rede e converte para [NetworkException] ou [ServerException].
  Exception _handleError(Object error) {
    if (error is SocketException ||
        error is TimeoutException ||
        error.toString().toLowerCase().contains('socket') ||
        error.toString().toLowerCase().contains('failed host lookup') ||
        error.toString().toLowerCase().contains('network is unreachable') ||
        error.toString().toLowerCase().contains('connection refused') ||
        error.toString().toLowerCase().contains('connection reset') ||
        error.toString().toLowerCase().contains('timed out') ||
        error.toString().toLowerCase().contains('clientexception')) {
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
          .neq('id', 100) // Rota 100 (Palmeira dos Índios - Maceió) não possui horários cadastrados
          .timeout(_timeout);

      final rotas = (response as List)
          .map((json) => RotaModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return rotas;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Busca cidades pelo nome (autocomplete).
  /// Se [termo] for fornecido, filtra via ILIKE usando o índice trigram.
  /// Se omitido, retorna todas as cidades ordenadas por nome.
  Future<List<String>> fetchCidades({String? termo}) async {
    try {
      var query = supabase.from('cidades').select('nome');

      if (termo != null && termo.trim().isNotEmpty) {
        // Sanitiza caracteres especiais de LIKE (% e _) para prevenir wildcards inesperados
        final termoLimpo = termo.trim().replaceAll('%', '').replaceAll('_', '');
        if (termoLimpo.isNotEmpty) {
          query = query.ilike('nome', '%$termoLimpo%');
        }
      }

      final response =
          await query.order('nome', ascending: true).timeout(_timeout);

      final cidades = (response as List)
          .map((json) => (json as Map<String, dynamic>)['nome'] as String)
          .toList();

      return cidades;
    } catch (e) {
      throw _handleError(e);
    }
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
}
