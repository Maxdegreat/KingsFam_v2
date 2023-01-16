part of 'package:kingsfam/screens/commuinity/commuinity_screen.dart';

Set<dynamic> cmPrivacySet = {
  CommuintyStatus.armormed,
  CommuintyStatus.shielded,
  RequestStatus.pending
};

Widget _mainScrollView(
    BuildContext context,
    CommuinityState state,
    Church cm,
    Widget? _ad,
    VoidCallback setStateCallBack,
    ScrollController scrollController) {
  // create list for mentioned rooms and reg rooms

  // load an ad for the cm content

  // ignore: unused_local_variable
  Color primaryColor = Colors.white;
  // ignore: unused_local_variable
  Color secondaryColor = Color(hc.hexcolorCode('#141829'));

  return RefreshIndicator(
    onRefresh: () async {
      context.read<CommuinityBloc>().add(CommunityInitalEvent(commuinity: cm));
    },
    child:  

        CustomScrollView(

          slivers: 
            [

              header(
                    cm: cm,
                    context: context,
                    cmBloc: context.read<CommuinityBloc>()
                ),


              SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(height: 8),
            
            postList(
              cm: cm,
              context: context,
              cmBloc: context.read<CommuinityBloc>(),
              ad: _ad,
            ),
        
            if (state.mentionedCords.length > 0) ... [
              showMentions(context, cm),
              SizedBox(height: 8),
            ],
        
            showRooms(context, cm),
        
            SizedBox(height: 8),
        
            showVoice(context, cm),
        
            SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
  );
}



