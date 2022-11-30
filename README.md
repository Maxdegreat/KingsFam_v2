# kingsfam

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
# KingsFam_v2_IOS



dynamic nativeAd = Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
            child: _isNativeAdLoaded
                ? Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Color(hc.hexcolorCode("#141829")),
                        gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Color(hc.hexcolorCode("#20263c")),
                              Color(hc.hexcolorCode("#141829"))
                            ]),
                        border:
                            Border.all(width: .5, color: Colors.blue[900]!)),
                    height: 80,
                    width: 200,
                    child: AdWidget(
                      ad: _nativeAd,
                    ),
                  )
                : null));