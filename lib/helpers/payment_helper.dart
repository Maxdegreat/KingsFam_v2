import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

const String StripeParishableKey =
    "pk_live_51LepZfCJ9MK5xgXMBHmITl7eKyBFuvqvfDqGuWhHCxUHaPHLQjvu9t9UEllAS2pujx7w1JVTBepaVgQjbwNwL6CI00dZTbeI9h";

class StripeCardPayWidget extends StatefulWidget {
  const StripeCardPayWidget({Key? key}) : super(key: key);

  @override
  State<StripeCardPayWidget> createState() => _StripeCardPayWidgetState();
}

class _StripeCardPayWidgetState extends State<StripeCardPayWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Card Form",
            style: Theme.of(context).textTheme.bodyText1,
          ),
          const SizedBox(height: 20),
          CardFormField(
            controller: CardFormEditController(),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {}, 
            child: Text("Pay")
          )
        ],
      ),
    );
  }
}
