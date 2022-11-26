//
//  AppDelegate.m
//  Runner
//
//  Created by Maximus on 11/20/22.
//

#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"

// COMPLETE: Import ListTileNativeAdFactory.h
#import "ListTileNativeAdFactory.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];

  // COMPLETE: Register ListTileNativeAdFactory
  ListTileNativeAdFactory *listTileFactory = [[ListTileNativeAdFactory alloc] init];
  [FLTGoogleMobileAdsPlugin registerNativeAdFactory:self
                                        factoryId:@"listTile"
                                  nativeAdFactory:listTileFactory];

  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
