import "dart:developer";

import "package:flutter/material.dart";
import "package:music_offline_player/screens/NowPlaying.dart";
import 'package:on_audio_query/on_audio_query.dart';
import "package:permission_handler/permission_handler.dart";
import "package:just_audio/just_audio.dart";
import "package:provider/provider.dart";
import 'package:music_offline_player/provider/song_model_provider.dart';

import "../provider/song_model_provider.dart";

class AllSongs extends StatefulWidget{
  const AllSongs({Key? key}) : super(key: key);

  @override
  _AllSongsState createState() => _AllSongsState();
}

class _AllSongsState extends State<AllSongs> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<SongModel> allSongs = [];

  playSong(String? uri) {
    try {
      _audioPlayer.setAudioSource(
          AudioSource.uri(
              Uri.parse(uri!)
          )
      );
      _audioPlayer.play();
    } on Exception {
      log("Cannot parse song");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestPermission();
  }

  void requestPermission() {
    Permission.storage.request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Group 1 Music Player 2023"),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          ],
        ),
        body: FutureBuilder<List<SongModel>>(
            future: _audioQuery.querySongs(
                sortType: null,
                orderType: OrderType.ASC_OR_SMALLER,
                uriType: UriType.EXTERNAL,
                ignoreCase: true
            ),
            builder: (context, item) {
              if (item.data == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (item.data!.isEmpty) {
                return const Center(child: Text("No song found"));
              }
              allSongs.addAll(item.data as Iterable<SongModel>);
              return Stack(
                children: [
                 ListView.builder(
                    itemCount: item.data!.length,
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 60),
                    itemBuilder: (context, index) =>
                        ListTile(
                          title: Text(item.data![index].displayNameWOExt),
                          subtitle: Text("${item.data![index].artist}"),
                          trailing: const Icon(Icons.more_horiz),
                          leading: QueryArtworkWidget(
                            id: item.data![index].id,
                            type: ArtworkType.AUDIO,
                            nullArtworkWidget: const Icon(Icons.music_note),
                          ),
                          onTap: () {
                            context.read<SongModelProvider>().setId(item.data![index].id);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      NowPlaying(songModelList: [item.data![index]],
                                        audioPlayer: _audioPlayer,),
                                )
                            );
                          },
                        ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: GestureDetector(
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  NowPlaying(songModelList: allSongs,
                                    audioPlayer: _audioPlayer,),
                            )
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(0, 0, 15, 15),
                        child: const CircleAvatar(
                          radius: 30,
                          child: Icon(Icons.play_arrow),
                        ),
                      ),
                    ),
                  )
                ],
              );
            }
        )
    );
  }
}