import 'package:flutter/material.dart';

import 'package:sonora/core/theme/theme.dart';

import 'package:sonora/services/playback_engine/playback_engine.dart';

import 'home_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,

      appBar: AppBar(
        title: Text('Sonora'),

        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },

              icon: Icon(Icons.menu),
            );
          }
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 190,
                  height: 320,
                  decoration: BoxDecoration(
                    color: context.colors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: const Center(child: Text('Player')),
                ),

                const Spacer(),

                Column(
                  children: [
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: context.colors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),

                      child: const Center(child: Text('Your artists')),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: context.colors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),

                      child: const Center(child: Text('Your playlists')),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 22),

            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 8,
                itemBuilder: (context, index) {
                  return Container(
                    width: 90,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: context.colors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: Center(child: Text('Your song feed')),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final engine = PlaybackEngine();

          await engine.open('assets/test.mp3');
          await engine.play();
        },
        child: const Icon(Icons.play_arrow),
      ),

      drawer: HomeDrawer(),
    );
  }
}