part of 'bottomnavbar_cubit.dart';

class BottomnavbarState extends Equatable {
  final BottomNavItem selectedItem;
  final VideoPlayerController? vidCtrl;
  final  bool showBottomNav;

  const BottomnavbarState({required this.selectedItem, this.vidCtrl, required this.showBottomNav});

  @override
  List<Object?> get props => [selectedItem, vidCtrl, showBottomNav];

  BottomnavbarState copyWith({
    BottomNavItem? selectedItem,
    VideoPlayerController? vidCtrl,
    bool? showBottomNav,
  }) {
    return BottomnavbarState(
      showBottomNav: showBottomNav ?? this.showBottomNav,
      selectedItem: selectedItem ?? this.selectedItem,
      vidCtrl: vidCtrl ?? this.vidCtrl,
    );
  }
}
