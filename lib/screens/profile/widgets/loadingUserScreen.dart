import 'package:flutter/material.dart';
import 'package:kingsfam/widgets/banner_image_widget.dart';
import 'package:kingsfam/widgets/roundContainerWithImgUrl.dart';

loadingUserScreen(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              BannerImage(
                isOpasaty: false,
                bannerImageUrl: '',
              ),
              Positioned(
                right: (MediaQuery.of(context).size.shortestSide / 2) - 40,
                left: (MediaQuery.of(context).size.shortestSide / 2) - 40,
                height: 55,
                bottom: -20,
                child: ContainerWithURLImg(
                    imgUrl: null,
                    width: 50,
                    height: 50,
                    pc: Theme.of(context).scaffoldBackgroundColor),
              ),
            ],
            clipBehavior: Clip.none,
          ),
          const SizedBox(height: 40),
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(7),
            ),
          ),
    
          const SizedBox(height: 40),
    
                  Container(
            height: 350,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(7),
            ),
          ),
        ],
      ),
    ),
  );
}
