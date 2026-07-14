import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mithka/chat/music_history.dart';
import 'package:mithka/chat/music_player_controller.dart';
import 'package:mithka/chat/music_playlist_service.dart';
import 'package:mithka/chat/shared_media_view.dart';
import 'package:mithka/l10n/app_localizations.dart';
import 'package:mithka/tdlib/td_models.dart';
import 'package:mithka/theme/theme_controller.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('music hub has playlist and music tabs with source chats', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final theme = ThemeController(prefs);
    final player = MusicPlayerController.shared;
    final track = ChatMessage(
      id: 10,
      isOutgoing: false,
      text: '',
      date: 1,
      chatId: 20,
      senderName: 'Played source',
      music: MessageMusic(
        title: 'Current song',
        performer: 'Artist',
        duration: 120,
        file: TdFileRef(id: 30),
      ),
    );
    player
      ..current = track
      ..queue = [track]
      ..hidden = false
      ..collapsed = false;
    addTearDown(() {
      player
        ..playlists = const []
        ..playedMusicChats = const []
        ..current = null
        ..queue = const []
        ..hidden = true
        ..collapsed = false;
      theme.dispose();
    });

    await tester.pumpWidget(
      ChangeNotifierProvider<ThemeController>.value(
        value: theme,
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: [AppLocalizations.delegate],
          supportedLocales: AppLocalizations.supportedLocales,
          home: SharedMediaView(
            chatId: 0,
            title: 'Music',
            initialTab: 5,
            displayTitle: AppStringKeys.profileDetailMusic,
            lockedTab: true,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Playlists'), findsOneWidget);
    expect(find.text('Music'), findsWidgets);
    expect(find.byType(GlobalMusicPlayerBar), findsOneWidget);

    // The hub refreshes its sources on entry. Seed the UI fixture after that
    // refresh so this remains a layout test rather than a TDLib service test.
    player
      ..playlists = const [MusicPlaylist(chatId: 40, title: 'Saved playlist')]
      ..playedMusicChats = const [
        PlayedMusicChat(chatId: 20, title: 'Played source', lastPlayedAt: 1000),
      ];
    await tester.tap(find.text('Playlists'));
    await tester.pump();

    expect(find.text('Saved playlist'), findsOneWidget);
    expect(find.text('Played chats'), findsOneWidget);
    expect(find.text('Played source'), findsOneWidget);
    final playerBottom = tester
        .getBottomLeft(find.byType(GlobalMusicPlayerBar))
        .dy;
    final bottomPlaylistLabel = tester
        .widgetList<Text>(find.text('Playlists'))
        .map((widget) => find.byWidget(widget))
        .map((finder) => tester.getCenter(finder).dy)
        .reduce((a, b) => a > b ? a : b);
    expect(playerBottom, lessThan(bottomPlaylistLabel));
  });
}
