import 'package:flutter/material.dart';
import 'package:kingsfam/models/models.dart';

class SnackTimeShopScreen extends StatelessWidget {
  const SnackTimeShopScreen({ Key? key }) : super(key: key);

  static const String routeName = "/snackTime";

  static Route route() {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (_) =>  SnackTimeShopScreen()
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("SnackTime!"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("---> What are snacks? <---"),
            SizedBox(height: 5),
            Text("Owned: 7 snackBar, 1 chips, 0 fruitBowls"),
            SizedBox(height: 3),
            Text("+ Snacks"),
            SizedBox(height: 5),
            mainPromotionView(),
      
          ],
        ),
      )
    );
  }
  
  Widget mainPromotionView({Post? post}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      child: Column(
        children: [
          Container(
            height: 150,
            width: double.infinity,
            child: PageView.builder(
              itemCount: 2,
              onPageChanged: (idx) => mainPromotionViewChanged(),
              itemBuilder: (context, index) {
                return Container(
                  height: 95,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: 
                  ),
                );
              } 
            ),
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text("Image"), SizedBox(width: 7), Text("User1 name")
            ],
          )
        ],
      ),
    );
  }

  void mainPromotionViewChanged() => {};

}