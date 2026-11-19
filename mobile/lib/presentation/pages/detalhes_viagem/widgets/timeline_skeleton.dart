import 'package:flutter/material.dart';
import 'package:passai/core/theme/app_colors.dart';

/// Skeleton de loading animado/estático para a timeline de itinerário
class TimelineSkeleton extends StatelessWidget {
  const TimelineSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (index) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 32,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.border,
                    ),
                  ),
                  if (index < 2)
                    Container(
                      width: 2,
                      height: 40,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: AppColors.border,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 200,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.border.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
