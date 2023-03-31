import 'package:flutter/material.dart';
import 'package:kingsfam/widgets/roundContainerWithImgUrl.dart';

msgsLoading(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ContainerWithURLImg(imgUrl: null, height: 35, width: 35, pc: Theme.of(context).colorScheme.secondary),
        const SizedBox(width: 15),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            
            Container(
              width: MediaQuery.of(context).size.width / 2,
              height: 7,
              color: Theme.of(context).colorScheme.secondary,
            ),

            const SizedBox(height: 7),

            Container(
              width: MediaQuery.of(context).size.width / 1.7,
              height: 7,
              color: Theme.of(context).colorScheme.secondary,
            )
          ],
        ),
      ],
    ),
  );
}