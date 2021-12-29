import 'package:flutter/material.dart';
import 'package:my_app/model/radio.dart';
import 'package:velocity_x/velocity_x.dart';

class ItemWidget extends StatelessWidget {
  const ItemWidget({Key? key, required this.item}) : super(key: key);

  final MyRadio item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () {
          print("${item.name} pressed");
        },
        leading: Image.network(item.image),
        title: "${item.tagline}".text.bold.make(),
        subtitle: "${item.desc}".text.textStyle(context.captionStyle).make(),
        trailing: "${item.name}".text.purple900.make(),
      ),
    );
  }
}
