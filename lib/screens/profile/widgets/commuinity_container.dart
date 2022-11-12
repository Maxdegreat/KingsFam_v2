import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:kingsfam/config/constants.dart';

import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/church/church_repository.dart';
import 'package:kingsfam/screens/commuinity/commuinity_screen.dart';
import 'package:kingsfam/widgets/widgets.dart';

// a list view of commuinitys that i am a part of yeahhhh

// howto: ---> 1) i need user crdentials to access the users commuinty list
// 2) streambuilder????

class CommuinityContainer extends StatefulWidget {
  const CommuinityContainer({ required this.cms, required this.ownerId });
  final List<Church?> cms;
  final String ownerId;
  @override
  State<CommuinityContainer> createState() => _CommuinityContainerState();
}

class _CommuinityContainerState extends State<CommuinityContainer> {
  @override
  Widget build(BuildContext context) {
    return widget.cms.length > 0 ? CommuinityListTile(widget.cms, context, widget.ownerId) : SizedBox.shrink();
  }
}


CommuinityListTile(List<Church?>cms, BuildContext context, String ownerId) {
  bool moreBtn = true;
  // make data for first two commuinitys
  Church? commuinity1 = cms[0];
  Church? commuinity2 = cms.length >= 2 ? cms[1] : null;

  bool greaterThan2 = cms.length >= 2 ? true : false;


  var oneCommuinitys = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FancyListTile(username: commuinity1!.name, imageUrl: commuinity1.imageUrl, onTap: null, isBtn: false, BR: 12, height: 12 , width: 12),
        ],
      );
  
  var twoCommuinitys = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(padding: const EdgeInsets.only(bottom: 5),
          child: FancyListTile(username: commuinity1.name, imageUrl: commuinity1.imageUrl, onTap: null, isBtn: false, BR: 12, height: 12 , width: 12),),
          greaterThan2 ? FancyListTile(username: commuinity2!.name, imageUrl: commuinity2.imageUrl, onTap: null, isBtn: false, BR: 12, height: 12 , width: 12) : SizedBox.shrink() ,
        ],
      );

  
  // make data for the listtile (when moreBtn == true)

  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0,),
    child: GestureDetector(
      onTap: () => showModalBottomSheet(
        
        backgroundColor: Color(hc.hexcolorCode('#141829')),
        context: context, builder: (context) {

                final _churchRepo = context.read<ChurchRepository>();
                
                return Container(
                  height: 200,
                  child: FutureBuilder(
                    future: _churchRepo.getCommuinitysUserIn(userrId: ownerId , limit: 7),
                    builder: (BuildContext context, AsyncSnapshot<List<Church>> snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (BuildContext context, int index) {
                          Church ch = snapshot.data![index];
                          return GestureDetector(
                            onTap: () => Navigator.of(context).pushNamed(CommuinityScreen.routeName, arguments: CommuinityScreenArgs(commuinity: ch)),
                            child: ListTile(
                              leading: ProfileImage(pfpUrl: ch.imageUrl, radius: 25,),
                              title: Text(ch.name),
                            ),
                          );
                        },
                      );
                      } else return SizedBox.shrink();
                    },
                  ),
                );
              }),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal:10 , vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("See More", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),),
                SizedBox(width: 10),
                Text(" communites",  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),)
              ],
            ), 
            SizedBox(height: 5,),
            Container(
              child: !moreBtn ? Container() : greaterThan2 ? twoCommuinitys : oneCommuinitys,
            ),
          ],
        ),
      ),
    ),
  );
}