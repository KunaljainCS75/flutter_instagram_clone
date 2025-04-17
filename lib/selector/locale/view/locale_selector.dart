import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_clone/l10n/l10n.dart';
import 'package:flutter_instagram_clone/selector/locale/bloc/locale_bloc.dart';
/// A drop down menu to select a new [Locale]
///
/// Requires a [LocaleBloc] to be provided in the widget tree
/// (usually above [MaterialApp])
class LocaleSelector extends StatelessWidget {
  const LocaleSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = context.watch<LocaleBloc>().state;

    return DropdownButton(
      key: const Key('localeSelector_dropdown'),
      onChanged: (locale) =>
          context.read<LocaleBloc>().add(LocaleChanged(locale)),
      value: locale,
      items: [
        DropdownMenuItem(
          value: const Locale('en', 'US'),
          child: Text(
            l10n.enOptionText,
            key: const Key('localeSelector_en_dropdownMenuItem'),
          ),
        ),
        DropdownMenuItem(
          value: const Locale('ru', 'RU'),
          child: Text(
            l10n.ruOptionText,
            key: const Key('localeSelector_ru_dropdownMenuItem'),
          ),
        ),
      ],
    );
  }
}

class LocaleModalOption extends StatelessWidget {
  const LocaleModalOption({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const LocaleSelector(),
      title: Text(context.l10n.languageText),
    );
  }
}
// The key in Flutter uniquely identifies widgets, 
// helping Flutter know which widget to update or keep during a rebuild. 
// In this code, the key ensures the dropdown and its items 
// retain their state (like the selected language) when the app's UI rebuilds. 
// It also helps in automated testing by making it easier to
// locate specific widgets like the dropdown or menu items.