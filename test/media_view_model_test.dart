import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itunes_media_app/view_model/media_selection_view_model.dart'; // Adjust import as necessary

void main() {
  late ProviderContainer container;
  late MediaViewModel mediaViewModel;

  setUp(() {
    container = ProviderContainer();
    mediaViewModel = container.read(mediaViewModelProvider.notifier);
  });

  tearDown(() {
    container.dispose();
  });

  test('initial state is empty', () {
    final state = container.read(mediaViewModelProvider);
    expect(state, isEmpty);
  });

  test('toggleSelection adds media type when not present', () {
    mediaViewModel.toggleSelection('movie');
    final state = container.read(mediaViewModelProvider);
    expect(state, contains('movie'));
  });

  test('toggleSelection removes media type when present', () {
    mediaViewModel.toggleSelection('movie');
    mediaViewModel.toggleSelection('movie');
    final state = container.read(mediaViewModelProvider);
    expect(state, isEmpty);
  });

  test('toggleSelection handles multiple types correctly', () {
    mediaViewModel.toggleSelection('movie');
    mediaViewModel.toggleSelection('music');
    final state = container.read(mediaViewModelProvider);
    expect(state, containsAll(['movie', 'music']));
  });

  test('mediaTypes list is correct', () {
    final mediaTypes = mediaViewModel.mediaTypes;
    expect(mediaTypes, containsAll([
      'movie',
      'podcast',
      'music',
      'musicVideo',
      'audiobook',
      'shortFilm',
      'tvShow',
      'software',
      'ebook',
    ]));
  });

  test('mediaKindMap has correct mappings', () {
    final mediaKindMap = mediaViewModel.mediaKindMap;
    expect(mediaKindMap['movie'], containsAll(['movieArtist', 'movie']));
    expect(mediaKindMap['music'], containsAll([
      'musicArtist', 'musicTrack', 'album', 'musicVideo', 'mix', 'song'
    ]));
  });
}
