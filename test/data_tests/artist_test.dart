import 'package:flutter_test/flutter_test.dart';

import 'package:sonora/data/artists/artist.dart';
import 'package:sonora/data/player_controller/track.dart';

void main() {
  group('normalizeArtist', () {
    test('normalizes artist name', () {
      expect(normalizeArtist('AC/DC'), 'ac/dc');
      expect(normalizeArtist('ac/dc '), 'ac/dc');
    });

    test('groups unknown artists under the same key', () {
      expect(normalizeArtist('<unknown>'), normalizeArtist(null));
      expect(normalizeArtist(null), normalizeArtist(''));
      expect(normalizeArtist('<unknown>'), normalizeArtist(''));
    });
  });

  group('groupByArtist', () {
    test('groups artists case-insensitively and trims whitespace', () {
      final tracks = [
        Track(
          id: '1',
          title: '',
          artist: 'AC/DC',
          source: '',
        ),
        Track(
          id: '2',
          title: '',
          artist: 'ac/dc',
          source: '',
        )
      ];

      final artists = groupByArtist(tracks);

      expect(artists, hasLength(1));
      expect(artists.first.key, 'ac/dc');
      expect(artists.first.trackIds, ['1', '2']);
    });

    test('groups unknown, null and empty artists together and puts them last', () {
      final tracks = [
        Track(id: '1', title: '', artist: null, source: ''),
        Track(id: '2', title: '', artist: 'Slipknot', source: ''),
        Track(id: '3', title: '', artist: '', source: ''),
        Track(id: '4', title: '', artist: '<unknown>', source: ''),
      ];

      final artists = groupByArtist(tracks);

      expect(artists, hasLength(2));

      expect(artists[0].name, 'Slipknot');
      expect(artists[1].name, 'Unknown artist');

      expect(artists[1].trackIds, ['1', '3', '4']);
    });

    test('shows the most frequent spelling of an artist name', () {
      final tracks = [
        Track(id: '1', title: '', artist: 'AC/DC', source: ''),
        Track(id: '2', title: '', artist: 'ac/dc', source: ''),
        Track(id: '3', title: '', artist: 'AC/DC', source: ''),
        Track(id: '4', title: '', artist: 'ac/dc', source: ''),
        Track(id: '5', title: '', artist: 'AC/DC', source: ''),
      ];

      final artists = groupByArtist(tracks);

      expect(artists, hasLength(1));
      expect(artists.first.name, 'AC/DC');
    });

    test('sorts artists alphabetically', () {
      final tracks = [
        Track(id: '1', title: '', artist: 'Metallica', source: ''),
        Track(id: '2', title: '', artist: 'AC/DC', source: ''),
        Track(id: '3', title: '', artist: 'Nirvana', source: ''),
        Track(id: '4', title: '', artist: 'Queen', source: ''),
      ];

      final artists = groupByArtist(tracks);

      expect(
        artists.map((artist) => artist.name).toList(),
        ['AC/DC', 'Metallica', 'Nirvana', 'Queen'],
      );
    });
  });

  test('groups and sorts artists correctly', () {
    final tracks = [
      Track(id: '1', title: '', artist: null, source: ''),
      Track(id: '2', title: '', artist: 'nirvana', source: ''),
      Track(id: '3', title: '', artist: 'AC/DC', source: ''),
      Track(id: '4', title: '', artist: '<unknown>', source: ''),
      Track(id: '5', title: '', artist: 'NIRVANA', source: ''),
      Track(id: '6', title: '', artist: 'ac/dc ', source: ''),
      Track(id: '7', title: '', artist: '', source: ''),
    ];

    final artists = groupByArtist(tracks);

    expect(
      artists.map((artist) => artist.name).toList(),
      ['AC/DC', 'nirvana', 'Unknown artist'],
    );

    expect(artists[0].trackIds, ['3', '6']);
    expect(artists[1].trackIds, ['2', '5']);
    expect(artists[2].trackIds, ['1', '4', '7']);
  });
}