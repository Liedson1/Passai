import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/domain/entities/detalhes_viagem.dart';

/// Helper para compartilhamento dos detalhes de uma viagem via clipboard
class DetalhesViagemShareHelper {
  DetalhesViagemShareHelper._();

  static void compartilhar(BuildContext context, DetalhesViagem detalhes) {
    final buffer = StringBuffer();
    buffer.writeln('🚐 *Passaí — Detalhes da Viagem*');
    buffer.writeln('Linha: ${detalhes.rota}');
    if (detalhes.via != null) buffer.writeln('Via: ${detalhes.via}');
    if (detalhes.horaSaida != null) buffer.writeln('Partida: ${detalhes.horaSaida}');
    if (detalhes.chegadaPrevista != null) {
      buffer.writeln('Chegada prevista: ${detalhes.chegadaPrevista}');
    }
    buffer.writeln('Tarifa: ${detalhes.preco} (por assento)');
    buffer.writeln(
      'Veículo: ${detalhes.veiculoNumero ?? "Van"} (${detalhes.veiculoModelo ?? ""})',
    );
    buffer.writeln('\nItinerário:');
    for (int i = 0; i < detalhes.itinerario.length; i++) {
      final p = detalhes.itinerario[i];
      buffer.writeln(
        '${i + 1}. ${p.parada} ${p.horario.isNotEmpty ? "(${p.horario})" : ""}',
      );
    }
    buffer.writeln('\nConsulte horários e itinerários no Passaí:');
    buffer.writeln('https://passai-al.vercel.app');

    Clipboard.setData(ClipboardData(text: buffer.toString()));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Expanded(child: Text('Detalhes copiados para a área de transferência!')),
          ],
        ),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
