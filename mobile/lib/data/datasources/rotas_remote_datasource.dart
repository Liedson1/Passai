import 'package:passai/core/network/supabase_client.dart';
import 'package:passai/data/models/horario_model.dart';
import 'package:passai/data/models/rota_model.dart';

/// Responsável por todas as queries ao Supabase.
/// Não contém lógica de negócio — apenas acesso remoto a dados.
class RotasRemoteDatasource {
  /// Busca todas as rotas ativas com nomes das cidades de origem e destino.
  Future<List<RotaModel>> fetchTodasAsRotas() async {
    final response = await supabase
        .from('rotas')
        .select('''
          id,
          distancia_km,
          tarifa,
          origem:cidades!rotas_origem_id_fkey(nome),
          destino:cidades!rotas_destino_id_fkey(nome)
        ''')
        .eq('ativa', true);

    return (response as List)
        .map((json) => RotaModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Busca todas as cidades cadastradas, ordenadas por nome.
  Future<List<String>> fetchCidades() async {
    final response = await supabase
        .from('cidades')
        .select('nome')
        .order('nome', ascending: true);

    return (response as List)
        .map((json) => (json as Map<String, dynamic>)['nome'] as String)
        .toList();
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
          .order('hora', ascending: true);

      return (response as List)
          .map((json) => HorarioModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Fallback: se a tabela alteracoes_horario ainda não estiver criada no Supabase
      final response = await supabase
          .from('horarios')
          .select('id, hora, sentido')
          .eq('rota_id', rotaId)
          .eq('sentido', sentido)
          .order('hora', ascending: true);

      return (response as List)
          .map((json) => HorarioModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
  }
}
