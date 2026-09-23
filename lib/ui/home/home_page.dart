import 'package:flutter/material.dart';
import 'package:sonora/core/theme/theme.dart';

import 'home_drawer.dart';
import 'home_player_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const HomeDrawer(),

      appBar: AppBar(
        titleSpacing: 8,
        title: const _Wordmark(),
        actions: const [
          _StatusPill(),
          SizedBox(width: 26),
        ],
      ),

      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 980;

            return ListView(
              padding: EdgeInsets.fromLTRB(wide ? 32 : 20, 20, wide ? 32 : 20, 36),
              children: [
                if (wide)
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 11, child: HomePlayerSection()),
                      SizedBox(width: 24),
                      Expanded(flex: 8, child: _LibraryPanel()),
                    ],
                  )
                else ...const [
                  HomePlayerSection(),
                  SizedBox(height: 24),
                  _LibraryPanel(),
                ],
                const SizedBox(height: 24),
                const _CollectionSection(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xffd84a4a),
            borderRadius: BorderRadius.circular(8),
          ),

          child: const Icon(
            Icons.graphic_eq_rounded,
            color: Colors.white, size: 19,
          ),
        ),

        const SizedBox(width: 9),
        Text(
          'SONORA',
          style: Theme
              .of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 2.2),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        border: Border.all(color: context.colors.outline),
        borderRadius: BorderRadius.circular(20),
      ),

      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            color: Color(0xFFD84A4A),
            size: 8,
          ),

          SizedBox(width: 6),
          Text(
            'LOCAL LIBRARY',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryPanel extends StatelessWidget {
  const _LibraryPanel();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _LibraryCard(
          icon: Icons.queue_music_rounded,
          label: 'Плейлисты',
          note: 'Соберите первый сет из треков',
        ),

        SizedBox(height: 12),
        _LibraryCard(
          icon: Icons.mic_none_rounded,
          label: 'Исполнители',
          note: 'Появятся после сканирования',
        ),

        SizedBox(height: 12),
        _LibraryCard(
          icon: Icons.favorite_border_rounded,
          label: 'Избранное',
          note: 'Сохраняйте любимое одним касанием',
        ),
      ],
    );
  }
}

class _LibraryCard extends StatelessWidget {
  const _LibraryCard({
    required this.icon,
    required this.label,
    required this.note,
  });

  final IconData icon;
  final String label;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        // color: const Color(0xff1a1b1e),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.outline),
      ),

      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: context.colors.outline,
              borderRadius: BorderRadius.circular(11),
            ),

            child: Icon(
              icon,
              color: const Color(0xffd3d5d8),
            ),
          ),

          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),
                Text(
                  note,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xff8e9197),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionSection extends StatelessWidget {
  const _CollectionSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colors.outline),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.library_music_outlined, size: 19),
              const SizedBox(width: 9),
              Text('Коллекция', style: Theme
                  .of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
              ),

              const Spacer(),
              const Text(
                'RECENTLY ADDED',
                style: TextStyle(
                  color: Color(0xff888b91),
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              )
            ],
          ),

          const SizedBox(height: 20),
          Container(height: 1, color: const Color(0xFF303237)),

          const SizedBox(height: 17),
          const Row(
            children: [
              Icon(
                Icons.album_outlined,
                color: Color(0xFF777A80),
              ),

              SizedBox(width: 13),
              Expanded(
                child: Text(
                  'Загрузите музыку, чтобы увидеть свою коллекцию',
                  style: TextStyle(
                    color: Color(0xFFAEB0B5),
                  ),
                ),
              ),

              Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xFF777A80),
              )
            ],
          ),
        ],
      ),
    );
  }
}