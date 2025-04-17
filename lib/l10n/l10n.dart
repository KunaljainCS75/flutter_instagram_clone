import 'package:flutter/widgets.dart';
import 'package:flutter_instagram_clone/l10n/arb/app_localizations.dart';

export 'package:flutter_instagram_clone/l10n/arb/app_localizations.dart';

export 'slang/translations.g.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
