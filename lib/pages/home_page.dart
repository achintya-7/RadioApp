// ignore_for_file: unused_local_variable, import_of_legacy_library_into_null_safe, unnecessary_null_comparison

import 'dart:convert';

import 'package:alan_voice/alan_voice.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  final sugg = [
    "Play",
    "Stop",
    "Play rock music",
    "Play 107 FM",
    "Play next",
    "Play 104 FM",
    "Pause",
    "Play previous",
    "Play pop music"
  ];

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    setupAlan();
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

  void setupAlan() {
    AlanVoice.addButton(
        "19757f5358faf644ea84ed84c7b4cf882e956eca572e1d8b807a3e2338fdd0dc/stage",
        buttonAlign: AlanVoice.BUTTON_ALIGN_RIGHT);

    AlanVoice.callbacks.add((command) => _handleCommand(command.data));
  }

  _handleCommand(Map<String, dynamic> response) {
    switch (response["command"]) {
      case "play":
        _playMusic(_selectedRadio.url);
        break;

      case "stop":
        _audioPlayer.stop();
        break;

      case "next":
        final index = _selectedRadio.id;
        MyRadio newradio;
        if (_isplaying == true) {
          _audioPlayer.stop();
        }
        if (index + 1 > MyRadioList.items.length) {
          newradio = MyRadioList.items.firstWhere((element) => element.id == 1);
          MyRadioList.items.remove(newradio);
          MyRadioList.items.insert(0, newradio);
        } else {
          newradio = MyRadioList.items
              .firstWhere((element) => element.id == index + 1);
          MyRadioList.items.remove(newradio);
          MyRadioList.items.insert(0, newradio);
        }
        _playMusic(newradio.url);
        break;

      case "prev":
        final index = _selectedRadio.id;
        MyRadio newradio;
        if (_isplaying == true) {
          _audioPlayer.stop();
        }
        if (index + 1 <= 0) {
          newradio = MyRadioList.items.firstWhere((element) => element.id == 1);
          MyRadioList.items.remove(newradio);
          MyRadioList.items.insert(0, newradio);
        } else {
          newradio = MyRadioList.items
              .firstWhere((element) => element.id == index - 1);
          MyRadioList.items.remove(newradio);
          MyRadioList.items.insert(0, newradio);
        }
        _playMusic(newradio.url);
        break;

      case "play_channel":
        _audioPlayer.stop();
        final id = response["id"];
        MyRadio newradio =
            MyRadioList.items.firstWhere((element) => element.id == id);
        MyRadioList.items.remove(newradio);
        MyRadioList.items.insert(0, newradio);
        _playMusic(newradio.url);
        break;

      default:
        print("Command was ${response["command"]}");
        break;
    }
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
    _selectedRadio = MyRadioList.items[0];
    _selectedColor = Color(int.tryParse(_selectedRadio.color)!);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Container(
          color: _selectedColor ?? AIColors.primaryColor2,
          child: MyRadioList.items != null
              ? [
                  100.heightBox,
                  "All channles".text.xl.white.semiBold.make(),
                  20.heightBox,
                  ListView(
                    padding: Vx.m0,
                    shrinkWrap: true,
                    children: MyRadioList.items
                        .map((e) => ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(e.icon),
                              ),
                              title: "${e.name} FM".text.white.make(),
                              subtitle: e.tagline.text.white.make(),
                            ))
                        .toList(),
                  )
                ].vStack()
              : const Offstage(),
        ),
      ),
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

          [
            AppBar(
              title: "Radio".text.xl4.bold.make().shimmer(
                    primaryColor: Vx.pink900,
                    secondaryColor: Colors.white,
                  ), // shimmer will add an animation on the text
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              centerTitle: true,
            ).p8().h(100),
            "Start with - HEY ALAN!".text.italic.semiBold.white.make(),
            VxSwiper.builder(
                itemCount: sugg.length,
                height: 40.0,
                enableInfiniteScroll: true,
                autoPlay: true,
                autoPlayAnimationDuration: 3.seconds,
                autoPlayCurve: Curves.linear,
                itemBuilder: (context, index) {
                  final s = sugg[index];
                  return Chip(
                    label: s.text.make(),
                    backgroundColor: Vx.randomColor,
                  );
                })
          ].vStack(alignment: MainAxisAlignment.start),

          30.heightBox,

          // a tinder swipper like widget
          MyRadioList.items.length > 3
              ? VxSwiper.builder(
                  itemCount: MyRadioList.items.length,
                  aspectRatio: context.mdWindowSize == MobileWindowSize.xsmall
                      ? 1.0
                      : context.mdWindowSize == MobileWindowSize.medium
                          ? 2.0
                          : 3.0,
                  enlargeCenterPage: true,
                  onPageChanged: (index) {
                    if (MyRadioList.items[index].color != null) {
                      final colorHex = MyRadioList.items[index].color;
                      _selectedColor = Color(int.tryParse(colorHex)!);
                      _selectedRadio = MyRadioList.items[index];
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
