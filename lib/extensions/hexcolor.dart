// Maximus Agubuzo
// 02/ 24 / 22
// this is a class that allows a string pased to recieve a color. 
// see below a dictionary of colors as string to repesent a color

// "pair" this is a data type that will be used to find key of map when itr and you need an index
// Pair = ['colorName', idx]
class Pair {

  // public data types
  String? hexColorName;
  int? hexColorIdx;
  List pair = List.filled(2, null);


  // constructor
  Pair (String hexColorName, int hexColorIdx) {
    this.hexColorName = hexColorName;
    this.hexColorIdx = hexColorIdx;
  }

  // public methods
  void insertColorName(String colorName) {
    pair[0] = colorName;
  }

  void insertColorIdx(int hexColorIdx) {
    pair[1] = hexColorIdx;
  }

  List getPair() => pair;

}

class HexColor {
  // public function
  hexcolorCode(String? colorHexCode) {
    if (colorHexCode == null) 
      colorHexCode = "FF0000 ";
    String colorNew = '0xff' + colorHexCode;
    colorNew = colorNew.replaceAll('#', '');
    int colorInt = int.parse(colorNew);
    return colorInt;
  }

  // pass a regestired string (color name) and return a hex color.
  // if you need an idx see docs below hint- use hexcolroCounter
  Map<String, String> hexColorMap = {
    'Neon Green' : '#B4F414',
    'Grass Green' : '#14F462',
    'Baby Blue' : '#14F4E0',
    'Purple Blue' : '#1425F4',
    'Real Purple' : '#9814F4',
    'HoTT Pink' : '#F414BE',
    'Blood Red' : '#E81010',
    'crown Gold' : '#FFC050'

  };

  Map<String, String> hexToColor = {
     '#B4F414' : 'Neon Green'  , 
     '#14F462' : 'Grass Green' , 
     '#14F4E0' : 'Baby Blue'   , 
     '#1425F4' : 'Purple Blue' , 
     '#9814F4' : 'Real Purple' , 
     '#F414BE' : 'HoTT Pink'   , 
     '#E81010' : 'Blood Red'   ,
     'crown Gold' : '#FFC050'  ,
  };
  // pass an int 0 - (len-1)  and returned its corrsponding color name
  // this works in union with the hexColorMap
  Map<int, String> hexcolorCounter = {
     0 : 'Neon Green',
     1 : 'Grass Green', 
     2 : 'Baby Blue',
     3 : 'Purple Blue',
     4 : 'Real Purple',
     5 : 'HoTT Pink',
     6 : 'Blood Red',
     7 : 'crown Gold',
  };
}

// HexColor dictionary

// Neon Green -> #B4F414

// grass Green -> #14F462 

// Baby Blue -> #14F4E0 

// purple Blue -> #1425F4

// real Purple -> #9814F4 

// Hot Pink -> #F414BE

// Blood Red -> #E81010

// Crown Gold -> FFC050