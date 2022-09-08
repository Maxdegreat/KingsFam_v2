import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class StripePayCardWidget extends StatefulWidget {
  StripePayCardWidget({Key? key, required this.cardTitle, required this.price})
      : super(key: key);
  final String cardTitle;
  final String price;
  @override
  State<StripePayCardWidget> createState() => _StripePayCardWidgetState();
}


class _StripePayCardWidgetState extends State<StripePayCardWidget> {
    String test_secret_key = "sk_test_51LepZfCJ9MK5xgXMTwuxT3vWb2BwgtX8QVMnDpwJdVhKh6Hul1hcQk7QiClO5qSAXcaGwxL6VviizHSjT9VGXZyV00tfpHrEQb";
    Map<String, dynamic>? _paymentIntent;



  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(widget.cardTitle),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: CardFormField(
                controller: CardFormEditController(),
                style: CardFormStyle(),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child:
                        ElevatedButton(onPressed: () {}, child: Text("Pay"))))
          ],
        ));
  }
}

class StripePayCard {
  
}
