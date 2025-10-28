import 'package:flutter/material.dart';

class CustomSwitchTile extends StatefulWidget {
  final String title;

  const CustomSwitchTile({Key? key, required this.title}) : super(key: key);

  @override
  _CustomSwitchTileState createState() => _CustomSwitchTileState();
}

class _CustomSwitchTileState extends State<CustomSwitchTile> {
  bool _value = false;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(widget.title),
      value: _value,
      onChanged: (bool value) {
        setState(() {
          _value = value;
        });
      },
      activeColor: const Color(0xFF1E88E5),
    );
  }
}
