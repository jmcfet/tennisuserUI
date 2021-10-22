import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';


class PlayVideo extends StatefulWidget {
  PlayVideo();

  @override
  _PlayVideoState createState() => new _PlayVideoState();
}
class _PlayVideoState extends State<PlayVideo> {
  static final formKey = new GlobalKey<FormState>();
  late YoutubePlayerController _controller;

  void initState() {
    super.initState();
     _controller = YoutubePlayerController(
      initialVideoId: 'tnAjM5XUxnU',
      params: YoutubePlayerParams(

        showControls: true,
        showFullscreenButton: true,
      ),
    );
  }
    @override
    Widget build(BuildContext context) {
      final int month = DateTime
          .now()
          .month;
      return MaterialApp(

        //   debugShowCheckedModeBanner: false,
          home: Scaffold(
              appBar: AppBar(
                title: Text('Landings MWF Tennis'),
              ),
              body: Center(
                  child: Container(
                    width:MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: YoutubePlayerIFrame(
                      controller: _controller,
                      aspectRatio: 16 / 9,
                    ),
                  )
              )
          )
      );
    }
  }

