import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/app_config.dart';
import '../../../core/app_strings.dart';
import '../../common/kitex_logo.dart';
import '../../common/kx_button.dart';
import '../../common/kx_card.dart';
import '../../common/kx_toast.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Блок с китом и кнопками на сообщества KITex.
class KitexLinksBlock extends StatelessWidget {
  final List<KitexLink> links;
  const KitexLinksBlock({super.key, required this.links});

  Future<void> _open(BuildContext context, KitexLink l) async {
    var ok = false;
    try {
      ok = await launchUrl(Uri.parse(l.url),
          mode: LaunchMode.externalApplication);
    } catch (_) {
      ok = false;
    }
    if (!ok && context.mounted) {
      KxToast.show(context, AppStrings.linkFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.kx;
    return KxCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: KitexLogo(variant: KitexLogoVariant.full, size: 110),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              AppConfig.appVersion,
              style: AppTextStyles.caption.copyWith(color: c.textSecondary),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              AppStrings.kitexTagline,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(color: c.textSecondary),
            ),
          ),
          for (final l in links) ...[
            const SizedBox(height: 12),
            KxButton.outline(
              label: l.title,
              icon: Icons.open_in_new,
              onPressed: () => _open(context, l),
            ),
          ],
        ],
      ),
    );
  }
}
