// ignore_for_file: unused_local_variable, import_of_legacy_library_into_null_safe, unnecessary_null_comparison

import 'dart:convert';

import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/utils/themes.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:my_app/model/radio.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late MyRadio _selectedRadio;
  Color _selectedColor = AIColors.primaryColor1;
  bool _isplaying = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    fetchRadios();

    _audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == AudioPlayerState.PLAYING) {
        _isplaying = true;
      } else {
        _isplaying = false;
      }
      setState(() {});
    });
  }

  _playMusic(String url) {
    _audioPlayer.play(url);
    // select the first url which satisfies the conditon {element.url == url}
    _selectedRadio =
        MyRadioList.items.firstWhere((element) => element.url == url);
    print(_selectedRadio.name);
    setState(() {});
  }

  fetchRadios() async {
    final radioJson = await rootBundle.loadString("assets/radio.json");
    var decodedData = jsonDecode(
        radioJson); // we will convert the string data of json into object
    var productsData = decodedData["radios"];
    MyRadioList.items =
        List.from(productsData).map((item) => MyRadio.fromMap(item)).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(),
      body: Stack(
        children: [
          // this is how we are getting a buitiful backround of 2 colors
          VxAnimatedBox()
              .size(context.screenWidth, context.screenHeight)
              .withGradient(LinearGradient(
                colors: [
                  AIColors.primaryColor2,
                  _selectedColor,
                  
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ))
              .make(),

          AppBar(
            title: "Radio".text.xl4.bold.make().shimmer(
                  primaryColor: Vx.pink900,
                  secondaryColor: Colors.white,
                ), // shimmer will add an animation on the text
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            centerTitle: true,
          ).p16().h(150),

          10.heightBox,

          // a tinder swipper like widget
          MyRadioList.items != null
              ? VxSwiper.builder(
                  itemCount: MyRadioList.items.length,
                  aspectRatio: 1.0,
                  enlargeCenterPage: true,
                  onPageChanged: (index) {
                    if(MyRadioList.items[index].color != null){
                      final colorHex = MyRadioList.items[index].color;
                      _selectedColor = Color(int.tryParse(colorHex)!);
                      setState(() {});
                    }
                    
                  },
                  itemBuilder: (context, index) {
                    final rad = MyRadioList.items[index];

                    return VxBox(
                            child: ZStack(
                      [
                        Positioned(
                          top: 0.0,
                          right: 0.0,
                          child: VxBox(
                            child:
                                rad.category.text.uppercase.white.make().px16(),
                          )
                              .height(35)
                              .black
                              .withRounded(value: 10)
                              .black
                              .alignCenter
                              .make(),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: VStack(
                            [
                              rad.name.text.xl3.white.bold.make(),
                              5.heightBox,
                              rad.tagline.text.sm.white.bold.make(),
                            ],
                            crossAlignment: CrossAxisAlignment.center,
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: [
                            Icon(
                              CupertinoIcons.play_circle,
                              color: Colors.white,
                            ),
                            10.heightBox,
                            "Tap to play".text.gray300.make(),
                          ].vStack(),
                        )
                      ],
                    ))
                        .clip(Clip.antiAlias)
                        .bgImage(DecorationImage(
                            image: NetworkImage(rad.image),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.2),
                                BlendMode.darken)))
                        .withRounded(value: 55)
                        .border(color: Colors.black, width: 4.5)
                        .make()
                        .onInkTap(() {
                      if (_isplaying) {
                        _audioPlayer.stop();
                        _playMusic(rad.url);
                      } else {
                        _playMusic(rad.url);
                      }
                    }).p16();
                  }).centered()
              : Center(
                  child: CircularProgressIndicator(
                  backgroundColor: Vx.white,
                )),
          Align(
            alignment: Alignment.bottomCenter,
            child: [
              if (_isplaying)
                "Playing Now - ${_selectedRadio.name} FM"
                    .text
                    .white
                    .makeCentered(),
              Icon(
                _isplaying
                    ? CupertinoIcons.stop_circle
                    : CupertinoIcons.play_circle,
                color: Colors.white,
                size: 55.0,
              ).onInkTap(() {
                if (_isplaying) {
                  _audioPlayer.stop();
                } else {
                  _playMusic(_selectedRadio.url);
                }
              }),
            ].vStack(),
          ).pOnly(bottom: context.percentHeight * 12)
        ],
        fit: StackFit.expand,
      ),
    );
  }
}
