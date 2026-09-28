import 'package:flutter/material.dart';
import '../../services/locale_service.dart';
import '../../theme/app_theme.dart';

/// Presentation mode for the [LanguageSelectorWidget].
enum LanguageSelectorMode {
  /// Compact icon/pill popup menu button for AppBars and navigation headers.
  compact,

  /// Full-width interactive card for settings screens and drawers.
  card,
}

/// Metadata representation for supported languages.
class LanguageOption {
  final String code;
  final String label;
  final String nativeLabel;
  final String flagEmoji;

  const LanguageOption({
    required this.code,
    required this.label,
    required this.nativeLabel,
    required this.flagEmoji,
  });
}

/// LanguageSelectorWidget — Universal Multi-Language Switcher (Module 22)
///
/// Provides both compact (AppBar) and full-width (Card/Settings) language
/// selectors. Connects reactively to [LocaleService] to switch languages
/// seamlessly across the entire application.
class LanguageSelectorWidget extends StatelessWidget {
  /// Display mode of the selector (compact pill vs. expanded card).
  final LanguageSelectorMode mode;

  /// Optional callback invoked after language switch.
  final ValueChanged<String>? onLanguageChanged;

  /// Optional custom background color for the button/card.
  final Color? backgroundColor;

  /// Supported languages configuration with flag emojis and native script names.
  static const List<LanguageOption> options = [
    LanguageOption(
      code: 'en',
      label: 'English',
      nativeLabel: 'English',
      flagEmoji: '🇺🇸',
    ),
    LanguageOption(
      code: 'ta',
      label: 'Tamil',
      nativeLabel: 'தமிழ்',
      flagEmoji: '🇮🇳',
    ),
    LanguageOption(
      code: 'hi',
      label: 'Hindi',
      nativeLabel: 'हिन्दी',
      flagEmoji: '🇮🇳',
    ),
  ];

  const LanguageSelectorWidget({
    super.key,
    this.mode = LanguageSelectorMode.compact,
    this.onLanguageChanged,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleService(),
      builder: (context, _) {
        final currentCode = LocaleService().languageCode;
        final currentOpt = options.firstWhere(
          (opt) => opt.code == currentCode,
          orElse: () => options.first,
        );

        if (mode == LanguageSelectorMode.compact) {
          return _buildCompactSelector(context, currentOpt);
        } else {
          return _buildCardSelector(context, currentCode);
        }
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Compact Mode (AppBar / Header Pill)
  // ---------------------------------------------------------------------------
  Widget _buildCompactSelector(BuildContext context, LanguageOption current) {
    return PopupMenuButton<String>(
      key: const ValueKey('language_selector_compact'),
      tooltip: 'Change Language / மொழியை மாற்று / भाषा बदलें',
      initialValue: current.code,
      onSelected: (newCode) async {
        await LocaleService().changeLocale(newCode);
        onLanguageChanged?.call(newCode);
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.borderSubtle, width: 1),
      ),
      elevation: 4,
      color: Colors.white,
      offset: const Offset(0, 44),
      itemBuilder: (context) {
        return options.map((opt) {
          final isSelected = opt.code == current.code;
          return PopupMenuItem<String>(
            key: ValueKey('lang_option_${opt.code}'),
            value: opt.code,
            child: Row(
              children: [
                Text(opt.flagEmoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        opt.nativeLabel,
                        style: AppTheme.getLocalizedTextStyle(
                          languageCode: opt.code,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 14,
                          color: isSelected ? AppTheme.primaryTeal : AppTheme.slateDark,
                        ),
                      ),
                      if (opt.code != 'en')
                        Text(
                          opt.label,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.slateBody,
                          ),
                        ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppTheme.primaryTeal,
                    size: 18,
                  ),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.borderSubtle,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(current.flagEmoji, style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 6),
            Text(
              current.nativeLabel,
              style: AppTheme.getLocalizedTextStyle(
                languageCode: current.code,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.slateDark,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: AppTheme.slateBody,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Card Mode (Drawer / Settings Full-Width)
  // ---------------------------------------------------------------------------
  Widget _buildCardSelector(BuildContext context, String currentCode) {
    return Container(
      key: const ValueKey('language_selector_card'),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.language_rounded,
                color: AppTheme.primaryTeal,
                size: 20,
              ),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Application Language / மொழி / भाषा',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.slateDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: options.map((opt) {
              final isSelected = opt.code == currentCode;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: GestureDetector(
                  key: ValueKey('lang_card_option_${opt.code}'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    await LocaleService().changeLocale(opt.code);
                    onLanguageChanged?.call(opt.code);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.emeraldLight.withValues(alpha: 0.4)
                          : AppTheme.bgOffWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryTeal
                            : AppTheme.borderSubtle,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(opt.flagEmoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                opt.nativeLabel,
                                style: AppTheme.getLocalizedTextStyle(
                                  languageCode: opt.code,
                                  fontSize: 15,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                  color: isSelected ? AppTheme.primaryTeal : AppTheme.slateDark,
                                ),
                              ),
                              Text(
                                opt.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected ? AppTheme.primaryDark : AppTheme.slateBody,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppTheme.primaryTeal,
                            size: 20,
                          )
                        else
                          Icon(
                            Icons.radio_button_unchecked_rounded,
                            color: AppTheme.slateBody.withValues(alpha: 0.4),
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
              );
          }).toList(),
          ),
        ],
      ),
    );
  }
}
