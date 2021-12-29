// ignore_for_file: unused_local_variable, import_of_legacy_library_into_null_safe

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/model/item_widgets.dart';
import 'package:my_app/utils/ai_util.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:my_app/model/radio.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    fetchRadios();
  }

  fetchRadios() async {
    await Future.delayed(Duration(seconds: 2));
    final radioJson = await rootBundle.loadString("assets/radio.json");
    var decodedData = jsonDecode(radioJson); // we will convert the string data of json into object
    var productsData = decodedData["radios"];
    MyRadioList.items = List.from(productsData).map((item) => MyRadio.fromMap(item)).toList();
    print(productsData);
    setState(() {});
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text("Catalog App"),
  //     ),
  //     body: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: List(),
  //     ),
  //   );



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
                  AIColors.primaryColor1,
                  AIColors.primaryColor2,
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

          // used in making a tinder like swipper
        ],
      ),
    );
  }
}

class List extends StatelessWidget {
  const List({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: (MyRadioList.items != null && MyRadioList.items.isNotEmpty)
          ? ListView.builder(
              itemCount: MyRadioList.items.length,
              itemBuilder: (context, index) {
                return ItemWidget(
                  item: MyRadioList.items[index],
                );
              },
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
