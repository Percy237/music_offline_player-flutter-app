import "dart:math";

import "package:flutter/material.dart";
import "package:just_audio_background/just_audio_background.dart";
import "package:music_offline_player/screens/AllSongs.dart";
import 'package:music_offline_player/provider/song_model_provider.dart';
import "package:provider/provider.dart";

Future<void> main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  runApp(ChangeNotifierProvider(
    create: (context) => SongModelProvider(),
    child: const Myapp(),
  ));
}


class Myapp extends StatelessWidget{
  const Myapp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: "Group 1 Music Player 2023",
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: AllSongs(),
    );
  }
}

