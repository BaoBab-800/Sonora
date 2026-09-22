import 'package:flutter/material.dart';

import 'package:sonora/core/theme/theme.dart';

import 'home_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar : AppBar(
        title: const Text('Sonora'),

        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },

              icon: const Icon(Icons.menu),
            );
          },
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: ListView(
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

            for(int i = 0; i < 10; i++)
              ListTile(
                title: Text('Your song feed'),
                onTap: () {},
              ),
          ],
        ),
      ),

      drawer: HomeDrawer(),
    );
  }
}