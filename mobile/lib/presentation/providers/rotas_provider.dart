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

/// Repositório concreto
final rotasRepositoryProvider = Provider<RotasRepository>(
  (ref) => RotasRepositoryImpl(ref.watch(rotasRemoteDatasourceProvider)),
);

/// Use case de busca de rotas
final buscarRotasUsecaseProvider = Provider<BuscarRotas>(
  (ref) => BuscarRotas(ref.watch(rotasRepositoryProvider)),
);

// ---------------------------------------------------------------------------
// Providers de estado
// ---------------------------------------------------------------------------

/// Lista de todas as cidades disponíveis (para os dropdowns)
final cidadesProvider = FutureProvider<List<String>>((ref) {
  return ref.watch(rotasRepositoryProvider).buscarCidades();
});

/// Lista de todas as rotas ativas (para a seção de rotas disponíveis)
final todasAsRotasProvider = FutureProvider<List<Rota>>((ref) {
  return ref.watch(rotasRepositoryProvider).buscarTodasAsRotas();
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

/// Resultado da busca de rotas (origem → destino)
final rotasBuscadasProvider = FutureProvider<List<Rota>>((ref) async {
  final origem = ref.watch(origemSelecionadaProvider);
  final destino = ref.watch(destinoSelecionadoProvider);

  if (origem == null || destino == null) return [];

  return ref.watch(buscarRotasUsecaseProvider).call(
        origem: origem,
        destino: destino,
      );
});
