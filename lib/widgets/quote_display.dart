import 'package:flutter/material.dart';

class QuoteDisplay extends StatelessWidget {
  final String quote;
  const QuoteDisplay({Key? key, required this.quote}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: double.infinity / 1.5),
      child: Align(
        alignment: Alignment.center,
        child: Text(quote),
      ),
    );
  }
}
