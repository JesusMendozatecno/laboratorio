import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';

/// Capa de carga superpuesta que bloquea la interacción.
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  final bool isLoading;
  final Widget child;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black54,
              child: Center(
                child: Card(
                  margin: const EdgeInsets.all(AppDimens.xl),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.xxl,
                      vertical: AppDimens.xl,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: scheme.primary),
                        if (message != null) ...[
                          const SizedBox(height: AppDimens.lg),
                          Text(
                            message!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}