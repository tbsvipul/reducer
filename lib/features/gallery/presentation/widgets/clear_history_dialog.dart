import 'package:flutter/material.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/l10n/app_localizations.dart';

class ClearHistoryDialog extends StatelessWidget {
  final VoidCallback onClear;

  const ClearHistoryDialog({super.key, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.clearHistoryTitle),
      content: Text(l10n.clearHistoryContent),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            onClear();
            Navigator.pop(context);
          },
          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
          child: Text(l10n.clear),
        ),
      ],
    );
  }
}
