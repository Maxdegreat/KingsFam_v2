part of 'bottomnavbar_cubit.dart';

class BottomnavbarState extends Equatable {
  
  final BottomNavItem selectedItem;
  final VideoPlayerController? vidCtrl;
  
  const BottomnavbarState({required this.selectedItem, this.vidCtrl});

  @override
  List<Object?> get props => [selectedItem, vidCtrl];

  BottomnavbarState copyWith({
    BottomNavItem? selectedItem,
    VideoPlayerController? vidCtrl,
  }) {
    return BottomnavbarState(
      selectedItem: selectedItem ?? this.selectedItem,
      vidCtrl: vidCtrl ?? this.vidCtrl,
    );
  }
}
