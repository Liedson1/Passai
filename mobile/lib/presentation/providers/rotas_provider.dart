import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:passai/data/datasources/rotas_remote_datasource.dart';
import 'package:passai/data/repositories/rotas_repository_impl.dart';
import 'package:passai/domain/entities/rota.dart';
import 'package:passai/domain/repositories/rotas_repository.dart';
import 'package:passai/domain/usecases/buscar_rotas.dart';

// ---------------------------------------------------------------------------
// Providers de infraestrutura
// ---------------------------------------------------------------------------

/// Datasource remoto — singleton compartilhado
final rotasRemoteDatasourceProvider = Provider<RotasRemoteDatasource>(
  (_) => RotasRemoteDatasource(),
);

/// Repositório concreto — exposto como [RotasRepositoryImpl] para permitir
/// acesso ao método [limparCache] no pull-to-refresh sem query dupla.
final rotasRepositoryImplProvider = Provider<RotasRepositoryImpl>(
  (ref) => RotasRepositoryImpl(ref.watch(rotasRemoteDatasourceProvider)),
);

/// Repositório pela interface de domínio (uso geral)
final rotasRepositoryProvider = Provider<RotasRepository>(
  (ref) => ref.watch(rotasRepositoryImplProvider),
);

/// Use case de busca de rotas
final buscarRotasUsecaseProvider = Provider<BuscarRotas>(
  (ref) => BuscarRotas(ref.watch(rotasRepositoryProvider)),
);

// ---------------------------------------------------------------------------
// Providers de estado
// ---------------------------------------------------------------------------

/// Lista de todas as rotas ativas — carregada uma única vez e cacheada em memória.
/// [cidadesProvider] e [cidadesConectadasProvider] derivam deste provider,
/// eliminando o double-fetch ao Supabase na inicialização da Home.
final todasAsRotasProvider = FutureProvider<List<Rota>>((ref) {
  return ref.watch(rotasRepositoryProvider).buscarTodasAsRotas();
});

/// Lista de cidades disponíveis — derivada de [todasAsRotasProvider] via cache.
/// Não faz query extra ao banco quando as rotas já estiverem carregadas.
final cidadesProvider = FutureProvider<List<String>>((ref) {
  return ref.watch(rotasRepositoryProvider).buscarCidades();
});

/// Busca reativa de cidades por termo — usado pelo autocomplete
final cidadesPorTermoProvider =
    FutureProvider.family<List<String>, String>((ref, termo) {
  return ref.watch(rotasRepositoryProvider).buscarCidades(termo: termo);
});

/// Retorna as cidades diretamente conectadas a uma [cidadeBase] por rotas ativas.
/// Se [cidadeBase] for nula ou vazia, retorna a lista completa de cidades.
final cidadesConectadasProvider =
    Provider.family<List<String>, String?>((ref, cidadeBase) {
  final todasCidades = ref.watch(cidadesProvider).valueOrNull ?? const <String>[];
  if (cidadeBase == null || cidadeBase.trim().isEmpty) {
    return todasCidades;
  }

  final rotasAsync = ref.watch(todasAsRotasProvider);
  final rotas = rotasAsync.valueOrNull ?? const <Rota>[];
  if (rotas.isEmpty) {
    return todasCidades;
  }

  final base = cidadeBase.trim().toLowerCase();
  final conectadas = <String>{};

  for (final rota in rotas) {
    final orig = rota.origem.trim().toLowerCase();
    final dest = rota.destino.trim().toLowerCase();

    if (orig == base) {
      conectadas.add(rota.destino.trim());
    } else if (dest == base) {
      conectadas.add(rota.origem.trim());
    }
  }

  if (conectadas.isEmpty) {
    return todasCidades;
  }

  final result = conectadas.toList()..sort((a, b) => a.compareTo(b));
  return result;
});

/// Notifier da busca de origem selecionada
final origemSelecionadaProvider = StateProvider<String?>((ref) => null);

/// Notifier da busca de destino selecionado
final destinoSelecionadoProvider = StateProvider<String?>((ref) => null);

/// Resultado da busca de rotas com sentido (origem → destino)
final rotasBuscadasComSentidoProvider =
    FutureProvider<List<RotaSearchResult>>((ref) async {
  final origem = ref.watch(origemSelecionadaProvider);
  final destino = ref.watch(destinoSelecionadoProvider);

  if (origem == null || destino == null) return [];

  return ref.watch(buscarRotasUsecaseProvider).buscarComSentido(
        origem: origem,
        destino: destino,
      );
});

/// Resultado da busca de rotas (origem → destino) — derivado sem fetch extra.
/// Extraído de [rotasBuscadasComSentidoProvider] para evitar chamada duplicada ao banco.
final rotasBuscadasProvider = Provider<List<Rota>>((ref) {
  final resultados = ref.watch(rotasBuscadasComSentidoProvider).valueOrNull ?? const <RotaSearchResult>[];
  return resultados.map((r) => r.rota).toList();
});
