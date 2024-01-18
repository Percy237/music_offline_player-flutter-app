import "package:flutter/material.dart";
import 'package:on_audio_query/on_audio_query.dart';
import "package:permission_handler/permission_handler.dart";

void main(){
  runApp(const Myapp());
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

class AllSongs extends StatefulWidget{
  const AllSongs({Key? key}) : super(key: key);

  @override
  _AllSongsState createState() => _AllSongsState();
}

class _AllSongsState extends State<AllSongs>{
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestPermission();
  }
  void requestPermission(){
    Permission.storage.request();
  }
  final _audioQuery = new OnAudioQuery();
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Group 1 Music Player 2023"),
        actions: [
          IconButton(onPressed: (){}, icon: const Icon(Icons.search)),
        ],
      ),
      body: FutureBuilder<List<SongModel>>(
        future: _audioQuery.querySongs(
          sortType: null,
          orderType: OrderType.ASC_OR_SMALLER,
          uriType: UriType.EXTERNAL,
          ignoreCase: true
        ),
        builder: (context, item){
          if(item.data == null){
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if(item.data!.isEmpty){
            return const Center(child: Text("no song found"));
          }
          return ListView.builder(itemBuilder: (context, index)=>ListTile(
          leading: const Icon(Icons.music_note),
          title:  Text(item.data![index].displayNameWOExt),
          subtitle: Text("${item.data![index].artist}"),
          trailing: const Icon(Icons.more_horiz),
          ),itemCount: item.data!.length,);
        }
      )
    );
  }
}