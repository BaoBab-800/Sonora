import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sonora/core/l10n/l10n.dart';
import 'package:sonora/core/theme/theme.dart';
import 'package:sonora/core/providers/app_providers.dart';

import '../seventh_page/seventh_page.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  bool _secretUnlocked = false;

  void _unlockSecret() {
    setState(() {
      _secretUnlocked = true;
    });
  }

  void _openSecret() {
    if (!_secretUnlocked) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SeventhPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.about,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          children: [
            _buildHeader(context),

            const SizedBox(height: 20),
            _buildSection(
              context,
              title: context.l10n.aboutSonora,
              child: Text(
                context.l10n.aboutDescription,
                style: TextStyle(
                  color: context.colors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 16),
            _buildSection(
              context,
              title: context.l10n.aboutFeatures,
              child: _buildFeatures(context),
            ),

            const SizedBox(height: 16),
            _buildLinksSection(context),

            const SizedBox(height: 24),
            VersionText(
              onTap: _secretUnlocked ? _openSecret : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 28,
      ),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFD84A4A),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.graphic_eq_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),

          const SizedBox(height: 14),
          SonoraLogoText(
            onSecretUnlocked: _unlockSecret,
          ),

          const SizedBox(height: 4),
          Text(
            'Local music player',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.outline,
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildFeatures(BuildContext context) {
    final features = [
      (icon: Icons.library_music_rounded, title: context.l10n.aboutLocalPlayback),
      (icon: Icons.favorite_rounded, title: context.l10n.aboutFavorites),
      (icon: Icons.queue_music_rounded, title: context.l10n.aboutPlaylists),
      (icon: Icons.shuffle_rounded, title: context.l10n.aboutShuffleRepeat),
    ];

    return Column(
      children: [
        for (final feature in features) ...[
          Row(
            children: [
              Icon(
                feature.icon,
                size: 20,
                color: context.colors.primary,
              ),

              const SizedBox(width: 12),
              Text(feature.title),
            ],
          ),

          if (feature != features.last)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Divider(
                height: 1,
                color: context.colors.outline.withValues(alpha: 0.5),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildLinksSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            context.l10n.aboutLinks,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        LinkTile(
          icon: Icons.code_rounded,
          text: context.l10n.aboutGithub,
          url: Uri.parse('https://github.com/BaoBab-800/Sonora'),
        ),

        const SizedBox(height: 8),
        LinkTile(
          icon: Icons.favorite_border_rounded,
          text: context.l10n.aboutSupport,
          url: Uri.parse('https://заглушка'),
        ),
      ],
    );
  }
}

class SonoraLogoText extends StatefulWidget {
  final VoidCallback onSecretUnlocked;

  const SonoraLogoText({
    super.key,
    required this.onSecretUnlocked,
  });

  @override
  State<SonoraLogoText> createState() => _SonoraLogoTextState();
}

class _SonoraLogoTextState extends State<SonoraLogoText> {
  int _tapCount = 0;
  bool _isAnimating = false;

  void _onTap() {
    _tapCount++;

    if (_tapCount >= 7) {
      _tapCount = 0;
      _playEasterEgg();
    }

    setState(() {});
  }

  Future<void> _playEasterEgg() async {
    setState(() {
      _isAnimating = true;
    });

    widget.onSecretUnlocked();
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    setState(() {
      _isAnimating = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.l10n.aboutYouFoundSomething,
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),

        backgroundColor: context.colors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedScale(
        scale: _isAnimating ? 1.15 : 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        child: Text(
          'SONORA',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 3,
          ),
        ),
      ),
    );
  }
}

class LinkTile extends ConsumerWidget {
  final IconData icon;
  final String text;
  final Uri url;

  const LinkTile({
    super.key,
    required this.icon,
    required this.text,
    required this.url,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(urlService);

    return Material(
      color: context.colors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => service.open(url),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 13,
          ),

          child: Row(
            children: [
              Icon(
                icon,
                size: 21,
                color: context.colors.primary,
              ),

              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const Icon(
                Icons.open_in_new_rounded,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VersionText extends ConsumerWidget {
  final VoidCallback? onTap;

  const VersionText({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final versionAsync = ref.watch(packageInfoProvider);

    return GestureDetector(
      onTap: onTap,
      child: versionAsync.when(
        data: (version) => Text(
          context.l10n.aboutVersion(version),
          style: TextStyle(
            color: context.colors.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        loading: () => const Text(
          'Loading...',
          style: TextStyle(fontSize: 12),
        ),
        error: (_, _) => const Text(
          'Unknown',
          style: TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}