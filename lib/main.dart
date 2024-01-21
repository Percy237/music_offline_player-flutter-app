import "dart:math";

import "package:flutter/material.dart";
import "package:music_offline_player/screens/AllSongs.dart";
import 'package:music_offline_player/provider/song_model_provider.dart';
import "package:provider/provider.dart";

void main(){
  runApp(ChangeNotifierProvider(
      create: (context) => SongModelProvider(),
    child: const Myapp(),
  )
  );
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

