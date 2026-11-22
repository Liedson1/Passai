import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:passai/core/constants/app_constants.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/core/theme/app_text_styles.dart';
import 'package:passai/domain/entities/detalhes_viagem.dart';
import 'package:passai/presentation/pages/detalhes_viagem/detalhes_viagem_page.dart';
import 'package:passai/presentation/pages/detalhes_viagem/widgets/detalhes_viagem_share_helper.dart';

/// Ações no rodapé da tela de detalhes (compartilhar e ver rota de volta)
class AcoesFooter extends StatelessWidget {
  const AcoesFooter({super.key, required this.detalhes, this.args});

  final DetalhesViagem detalhes;
  final DetalhesViagemArgs? args;

  @override
  Widget build(BuildContext context) {
    final origemVolta = detalhes.destino ??
        (detalhes.itinerario.isNotEmpty ? detalhes.itinerario.last.parada : '');
    final destinoVolta = detalhes.origem ??
        (detalhes.itinerario.isNotEmpty ? detalhes.itinerario.first.parada : '');

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () => DetalhesViagemShareHelper.compartilhar(
              context,
              detalhes,
              rotaId: args?.rotaId,
              sentido: args?.sentido,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.button),
              ),
            ),
            icon: const Icon(Icons.share_rounded, size: 18),
            label: Text(
              'Compartilhar Detalhes da Viagem',
              style: AppTextStyles.bodyBold(fontSize: 14, color: Colors.white),
            ),
          ),
        ),
        if (origemVolta.isNotEmpty && destinoVolta.isNotEmpty) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: () {
                final sentidoInverso = args?.sentido == 'IDA' ? 'volta' : 'ida';
                context.push(
                  '${AppRoutes.resultados}?origem=${Uri.encodeComponent(origemVolta)}&destino=${Uri.encodeComponent(destinoVolta)}&sentido=$sentidoInverso',
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.button),
                ),
              ),
              icon: const Icon(Icons.swap_horiz_rounded, size: 16),
              label: Text(
                'Ver Horários de Volta ($origemVolta ➔ $destinoVolta)',
                style: AppTextStyles.bodySemibold(fontSize: 13, color: AppColors.primary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
