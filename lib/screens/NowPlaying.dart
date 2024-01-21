import "dart:developer";

import "package:flutter/material.dart";
import "package:just_audio/just_audio.dart";
import "package:just_audio_background/just_audio_background.dart";
import 'package:music_offline_player/provider/song_model_provider.dart';
import "package:on_audio_query/on_audio_query.dart";
import "package:provider/provider.dart";

class NowPlaying extends StatefulWidget {
  const NowPlaying(
      {super.key, required this.songModelList, required this.audioPlayer});
  final List<SongModel> songModelList;
  final AudioPlayer audioPlayer;

  @override
  State<NowPlaying> createState() => _NowPlayingState();
}

class _NowPlayingState extends State<NowPlaying> {
  Duration _duration = const Duration();
  Duration _position = const Duration();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  List<AudioSource> songList = [];

  int currentIndex = 0;

  void popBack() {
    Navigator.pop(context);
  }

  void seekToSeconds(int seconds) {
    Duration duration = Duration(seconds: seconds);
    widget.audioPlayer.seek(duration);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    playSong();
  }

  void playSong() {
    try {
      for (var element in widget.songModelList) {
        songList.add(AudioSource.uri(
          Uri.parse(element.uri!),
          tag: MediaItem(
            id: '${element.id}',
            album: '${element.album}',
            title: '${element.displayNameWOExt}',
            artUri: Uri.parse(element.id.toString()),
          ),
        ));
      }
      widget.audioPlayer
          .setAudioSource(ConcatenatingAudioSource(children: songList));
      widget.audioPlayer.play();
      _isPlaying = true;
    } on Exception {
      log("Cannot parse song");
    }
    widget.audioPlayer.durationStream.listen((d) {
      setState(() {
        _duration = d!;
      });
    });
    widget.audioPlayer.positionStream.listen((p) {
      setState(() {
        _position = p;
      });
      listenToEvent();
      listenToSongIndex();
    });
  }

  void listenToEvent() {
    widget.audioPlayer.playerStateStream.listen((state) {
      if (state.playing) {
        setState(() {
          _isPlaying = true;
        });
      } else {
        setState(() {
          _isPlaying = false;
        });
      }
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  void listenToSongIndex() {
    widget.audioPlayer.currentIndexStream.listen((event) {
      setState(() {
        if (event != null) {
          currentIndex = event;
        }
        context
            .read<SongModelProvider>()
            .setId(widget.songModelList[currentIndex].id);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back_ios)),
              SizedBox(
                height: 30.0,
              ),
              Center(
                  child: Column(children: [
                Center(
                  child: ArtWorkWidget(),
                ),
                SizedBox(
                  height: 30.0,
                ),
                Text(
                  widget.songModelList[currentIndex].displayNameWOExt,
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Text(
                  widget.songModelList[currentIndex].artist.toString(),
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                  style: TextStyle(fontSize: 20.0),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  children: <Widget>[
                    Text(_position.toString().split(".")[0]),
                    Expanded(
                        child: Slider(
                      min: const Duration(microseconds: 0).inSeconds.toDouble(),
                      value: _position.inSeconds.toDouble(),
                      max: _duration.inSeconds.toDouble(),
                      onChanged: (value) {
                        setState(() {
                          changeTopSeconds(value.toInt());
                          value = value;
                        });
                      },
                    )),
                    Text(_duration.toString().split(".")[0]),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                        onPressed: () {
                          if (widget.audioPlayer.hasPrevious) {
                            widget.audioPlayer.seekToPrevious();
                          }
                        },
                        icon: const Icon(
                          Icons.skip_previous,
                          size: 40.0,
                        )),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            if (_isPlaying) {
                              widget.audioPlayer.pause();
                            } else {
                              widget.audioPlayer.play();
                            }
                            _isPlaying = !_isPlaying;
                          });
                        },
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 40.0,
                        )),
                    IconButton(
                        onPressed: () {
                          if (widget.audioPlayer.hasNext) {
                            widget.audioPlayer.seekToNext();
                          }
                        },
                        icon: const Icon(Icons.skip_next, size: 40.0)),
                  ],
                )
              ]))
            ],
          ),
        ),
      ),
    );
  }

  void changeTopSeconds(int seconds) {
    Duration duration = Duration(seconds: seconds);
    widget.audioPlayer.seek(duration);
  }
}

class ArtWorkWidget extends StatelessWidget {
  const ArtWorkWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return QueryArtworkWidget(
      id: context.watch<SongModelProvider>().id,
      type: ArtworkType.AUDIO,
      artworkHeight: 200,
      artworkWidth: 200,
      artworkFit: BoxFit.cover,
      nullArtworkWidget: const Icon(
        Icons.music_note,
        size: 200,
      ),
    );
  }
}
