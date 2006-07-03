//
//  SystemAction.h
//  Spark
//
//  Created by Fox on Wed Feb 18 2004.
//  Copyright (c) 2004 Shadow Lab. All rights reserved.
//

#import <SparkKit/SparkKit.h>

typedef enum {
  kSystemLogOut = 0,
  kSystemSleep,
  kSystemRestart,
  kSystemShutDown,
  kSystemFastLogOut,
  kSystemScreenSaver,
  /* System event */
  kSystemMute,
  kSystemEject,
  kSystemVolumeUp,
  kSystemVolumeDown,
} SystemActionType;

extern NSString * const kSystemActionBundleIdentifier;

#define kSystemActionBundle		[NSBundle bundleWithIdentifier:kSystemActionBundleIdentifier]

@interface SystemAction : SparkAction <NSCoding, NSCopying> {
  SystemActionType sa_action;
}

- (SystemActionType)action;
- (void)setAction:(SystemActionType)anAction;

- (void)logout;
- (void)sleep;
- (void)restart;
- (void)shutDown;
- (void)fastLogout;
- (void)screenSaver;

@end
