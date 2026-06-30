#!/usr/bin/env python3
"""Move Han-containing Dart string literals behind identifier-based l10n keys.

This is intentionally mechanical: it keeps current zh-Hans copy as the source
locale, gives every migrated string a stable ASCII key, and rewrites Dart code
to call AppStrings.t(AppStringKeys.<key>). Analyzer cleanup is expected after a
large run because const/switch contexts usually need small structural edits.
"""

from __future__ import annotations

import json
import keyword
import re
from dataclasses import dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / "lib"
L10N_FILE = LIB / "l10n" / "app_localizations.dart"
KEY_PREFIX_STOP = {"view", "screen", "controller", "manager", "model"}


def has_han(text: str) -> bool:
    return any("\u4e00" <= ch <= "\u9fff" for ch in text)


def camel(parts: list[str]) -> str:
    cleaned: list[str] = []
    for part in parts:
        for token in re.findall(r"[A-Za-z0-9]+", part):
            if token:
                cleaned.append(token.lower())
    if not cleaned:
        return "string"
    first, *rest = cleaned
    return first + "".join(item.capitalize() for item in rest)


def file_prefix(path: Path) -> str:
    rel = path.relative_to(LIB).with_suffix("")
    parts: list[str] = []
    for piece in rel.parts:
        for token in piece.split("_"):
            if token and token.lower() not in KEY_PREFIX_STOP:
                parts.append(token)
    return camel(parts)


def key_from_english(value: str) -> str | None:
    value = value.replace("...", " ").replace("…", " ")
    words = re.findall(r"[A-Za-z0-9]+", value)
    if not words:
        return None
    words = words[:7]
    key = camel(words)
    if not key or key in keyword.kwlist or key[0].isdigit():
        return None
    return key


def key_from_source_or_fail(prefix: str, source: str) -> str:
    key = key_from_english(source)
    if key is not None:
        return prefix + key[:1].upper() + key[1:]
    raise ValueError(
        "Cannot derive a meaningful localization key for "
        f"{source!r}. Add an English semantic key manually instead of using a "
        "generated numeric/hash key."
    )


def dart_quote(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def dart_expr_string(value: str) -> str:
    escaped = value.replace("\\", "\\\\").replace("'", "\\'")
    return "'" + escaped + "'"


@dataclass(frozen=True)
class Literal:
    start: int
    end: int
    quote: str
    raw: str
    value: str
    interpolated: bool


def strip_comments_mask(text: str) -> list[bool]:
    in_line = False
    in_block = False
    mask = [False] * len(text)
    i = 0
    while i < len(text):
        if in_line:
            mask[i] = True
            if text[i] == "\n":
                in_line = False
            i += 1
            continue
        if in_block:
            mask[i] = True
            if text.startswith("*/", i):
                mask[i + 1] = True
                in_block = False
                i += 2
            else:
                i += 1
            continue
        if text.startswith("//", i):
            mask[i] = mask[i + 1] = True
            in_line = True
            i += 2
            continue
        if text.startswith("/*", i):
            mask[i] = mask[i + 1] = True
            in_block = True
            i += 2
            continue
        i += 1
    return mask


def parse_literals(text: str) -> list[Literal]:
    comments = strip_comments_mask(text)
    literals: list[Literal] = []
    i = 0
    while i < len(text):
        if comments[i]:
            i += 1
            continue
        raw_prefix = False
        start = i
        if text[i] in "rR" and i + 1 < len(text) and text[i + 1] in "'\"":
            raw_prefix = True
            i += 1
        if text[i] not in "'\"":
            i += 1
            continue
        quote = text[i]
        triple = text.startswith(quote * 3, i)
        q = quote * (3 if triple else 1)
        content_start = i + len(q)
        j = content_start
        escaped = False
        while j < len(text):
            if not raw_prefix and not triple and not escaped and text[j] == "\\":
                escaped = True
                j += 1
                continue
            if not escaped and text.startswith(q, j):
                raw = text[start : j + len(q)]
                value = text[content_start:j]
                literals.append(
                    Literal(
                        start=start,
                        end=j + len(q),
                        quote=q,
                        raw=raw,
                        value=value,
                        interpolated=("$" in value),
                    )
                )
                i = j + len(q)
                break
            escaped = False
            j += 1
        else:
            i += 1
    return literals


def extract_existing_translations() -> dict[str, dict[str, str]]:
    if not L10N_FILE.exists():
        return {}
    text = L10N_FILE.read_text()
    result: dict[str, dict[str, str]] = {}
    for locale in ["zhHans", "zhHant", "ja", "ko", "en", "fr", "es", "de"]:
        match = re.search(rf"'{locale}':\s*\{{(?P<body>.*?)\n\s*\}},", text, re.S)
        if not match:
            continue
        for key, value in re.findall(
            r"'((?:\\'|[^'])+)':\s*'((?:\\'|[^'])*)',", match.group("body")
        ):
            source = key.replace("\\'", "'")
            translated = value.replace("\\'", "'")
            result.setdefault(source, {})[locale] = translated
    return result


def interpolation_template(value: str) -> tuple[str, list[str]]:
    placeholders: list[str] = []
    out: list[str] = []
    i = 0
    while i < len(value):
        if value[i] != "$":
            out.append(value[i])
            i += 1
            continue
        if i + 1 < len(value) and value[i + 1] == "{":
            depth = 1
            j = i + 2
            while j < len(value) and depth:
                if value[j] == "{":
                    depth += 1
                elif value[j] == "}":
                    depth -= 1
                j += 1
            expr = value[i + 2 : j - 1].strip()
            name = f"value{len(placeholders) + 1}"
            placeholders.append(expr)
            out.append("{" + name + "}")
            i = j
            continue
        m = re.match(r"\$([A-Za-z_][A-Za-z0-9_]*)", value[i:])
        if m:
            name = f"value{len(placeholders) + 1}"
            placeholders.append(m.group(1))
            out.append("{" + name + "}")
            i += len(m.group(0))
            continue
        out.append("$")
        i += 1
    return "".join(out), placeholders


def replacement_for(key: str, placeholders: list[str]) -> str:
    base = f"AppStrings.t(AppStringKeys.{key}"
    if placeholders:
        items = ", ".join(
            f"{dart_expr_string(f'value{i + 1}')}: {expr}"
            for i, expr in enumerate(placeholders)
        )
        return f"{base}, {{{items}}})"
    return base + ")"


def ensure_import(text: str) -> str:
    imp = "import 'package:mithka/l10n/app_localizations.dart';"
    if imp in text:
        return text
    matches = list(re.finditer(r"^import .+;\n", text, re.M))
    if matches:
        return text[: matches[-1].end()] + imp + "\n" + text[matches[-1].end() :]
    return imp + "\n\n" + text


def generate_l10n(keys: dict[str, dict[str, str]]) -> str:
    key_lines = "\n".join(
        f"  static const {key} = '{key}';" for key in sorted(keys)
    )

    locale_maps = []
    for locale in ["zhHans", "zhHant", "ja", "ko", "en", "fr", "es", "de"]:
        locale_maps.append(f"  '{locale}': {{")
        for key in sorted(keys):
            value = keys[key].get(locale) or keys[key].get("zhHans") or key
            locale_maps.append(f"    '{key}': {dart_quote(value)},")
        locale_maps.append("  },")

    locale_body = "\n".join(locale_maps)
    return f"""import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class AppLocalizations {{
  const AppLocalizations(this.locale);

  final Locale locale;

  static const fallbackLocale = Locale('en');
  static const supportedLocales = [
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    Locale('ja'),
    Locale('ko'),
    Locale('en'),
    Locale('fr'),
    Locale('es'),
    Locale('de'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static bool isSupportedLocale(Locale locale) =>
      supportedLocales.any((supported) {{
        if (supported.languageCode != locale.languageCode) return false;
        if (supported.scriptCode == null) return true;
        return supported.scriptCode == locale.scriptCode ||
            (supported.scriptCode == 'Hans' &&
                locale.languageCode == 'zh' &&
                locale.scriptCode == null);
      }});

  static Locale resolve(Locale locale) {{
    if (locale.languageCode == 'zh') {{
      final isTraditional =
          locale.scriptCode == 'Hant' ||
          locale.countryCode == 'TW' ||
          locale.countryCode == 'HK' ||
          locale.countryCode == 'MO';
      return isTraditional
          ? const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')
          : const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans');
    }}
    return supportedLocales.firstWhere(
      (supported) => supported.languageCode == locale.languageCode,
      orElse: () => fallbackLocale,
    );
  }}

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations) ??
      const AppLocalizations(fallbackLocale);

  static String localeKeyFor(Locale locale) {{
    if (locale.languageCode == 'zh') {{
      return locale.scriptCode == 'Hant' ||
              locale.countryCode == 'TW' ||
              locale.countryCode == 'HK' ||
              locale.countryCode == 'MO'
          ? 'zhHant'
          : 'zhHans';
    }}
    return locale.languageCode;
  }}

  String get _key => localeKeyFor(locale);

  String t(String key, [Map<String, Object?> placeholders = const {{}}]) =>
      AppStrings.tForLocale(_key, key, placeholders);

  String format(String key, String value) =>
      t(key, {{'value1': value, 'value': value}});
}}

extension LocalizedString on String {{
  String l10n(BuildContext context) => AppLocalizations.of(context).t(this);
}}

extension AppLocalizationsContext on BuildContext {{
  AppLocalizations get l10n => AppLocalizations.of(this);
}}

abstract final class AppStringKeys {{
{key_lines}
}}

abstract final class AppStrings {{
  static String t(String key, [Map<String, Object?> placeholders = const {{}}]) {{
    final locale = AppLocalizations.resolve(Locale(Intl.getCurrentLocale()));
    return tForLocale(AppLocalizations.localeKeyFor(locale), key, placeholders);
  }}

  static String tForLocale(
    String localeKey,
    String key, [
    Map<String, Object?> placeholders = const {{}},
  ]) {{
    var value = _messages[localeKey]?[key] ?? _messages['en']?[key] ?? key;
    placeholders.forEach((placeholder, replacement) {{
      value = value.replaceAll('{{$placeholder}}', '$replacement');
    }});
    return value;
  }}
}}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {{
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.isSupportedLocale(locale);

  @override
  Future<AppLocalizations> load(Locale locale) {{
    final resolved = AppLocalizations.resolve(locale);
    Intl.defaultLocale = resolved.toLanguageTag();
    return SynchronousFuture(AppLocalizations(resolved));
  }}

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}}

const _messages = {{
{locale_body}
}};
"""


def main() -> None:
    existing = extract_existing_translations()
    source_to_key: dict[str, str] = {}
    entries: dict[str, dict[str, str]] = {}
    counters: dict[str, int] = {}

    files = sorted(
        p
        for p in LIB.rglob("*.dart")
        if "l10n/app_localizations.dart" not in p.as_posix()
    )

    for path in files:
        text = path.read_text()
        literals = [
            lit
            for lit in parse_literals(text)
            if has_han(lit.value) and not lit.raw.startswith("r")
        ]
        if not literals:
            continue
        prefix = file_prefix(path)
        replacements: list[tuple[int, int, str]] = []
        for lit in literals:
            template, placeholders = interpolation_template(lit.value)
            source_for_key = template
            key = source_to_key.get(source_for_key)
            if key is None:
                known = existing.get(source_for_key, {})
                english = known.get("en")
                key = key_from_english(english or "")
                if key is None:
                    key = key_from_source_or_fail(prefix, source_for_key)
                while key in entries and entries[key]["zhHans"] != source_for_key:
                    key += "Value"
                source_to_key[source_for_key] = key
                entries[key] = {
                    "zhHans": known.get("zhHans", source_for_key),
                    "zhHant": known.get("zhHant", source_for_key),
                    "ja": known.get("ja", source_for_key),
                    "ko": known.get("ko", source_for_key),
                    "en": known.get("en", source_for_key),
                    "fr": known.get("fr", known.get("en", source_for_key)),
                    "es": known.get("es", known.get("en", source_for_key)),
                    "de": known.get("de", known.get("en", source_for_key)),
                }
            replacements.append((lit.start, lit.end, replacement_for(key, placeholders)))

        new_text = text
        for start, end, replacement in reversed(replacements):
            new_text = new_text[:start] + replacement + new_text[end:]
        new_text = ensure_import(new_text)
        path.write_text(new_text)

    L10N_FILE.write_text(generate_l10n(entries))
    print(f"migrated {sum(counters.values())} unique file-scoped strings")
    print(f"total l10n keys: {len(entries)}")


if __name__ == "__main__":
    main()
