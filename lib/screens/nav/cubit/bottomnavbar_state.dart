part of 'bottomnavbar_cubit.dart';

class BottomnavbarState extends Equatable {
  
  final BottomNavItem selectedItem;
  
  const BottomnavbarState({required this.selectedItem});

  @override
  List<Object> get props => [selectedItem];
}
