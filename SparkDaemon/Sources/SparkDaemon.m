/*
 *  SparkDaemon.m
 *  SparkServer
 *
 *  Created by Black Moon Team.
 *  Copyright (c) 2004 - 2006 Shadow Lab. All rights reserved.
 */

#import "SparkDaemon.h"
#import "SDAEHandlers.h"

#import <SparkKit/SparkKit.h>

#import <SparkKit/SparkLibrary.h>
#import <SparkKit/SparkObjectSet.h>
/* Display alert */
#import <SparkKit/SparkActionPlugIn.h>

#import <SparkKit/SparkAlert.h>
#import <SparkKit/SparkAction.h>
#import <SparkKit/SparkTrigger.h>
#import <SparkKit/SparkApplication.h>

#import <ShadowKit/SKProcessFunctions.h>

#if defined (DEBUG)
#import <ShadowKit/SKAEFunctions.h>
#import <HotKeyToolKit/HotKeyToolKit.h>
#endif

int main(int argc, const char *argv[]) {
#if defined (DEBUG)
  SKAEDebug = YES;
  HKTraceHotKeyEvents = YES;
#endif
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSApplicationLoad();
  SparkDaemon *server;
  if (server = [[SparkDaemon alloc] init]) {
    /* Cleanup pool */
    [pool release];
    pool = [[NSAutoreleasePool alloc] init];
    [server run];
  } else {
    // Run Alert panel ?
    SDSendStateToEditor(kSparkDaemonError);
  }
  [server release];
  
  [pool release];
  return 0;
}

static
OSErr SparkDaemonAEQuitHandler(const AppleEvent *theAppleEvent, AppleEvent *reply, long handlerRefcon) {
  ShadowCTrace();
  [NSApp terminate:nil];
  return noErr;
}

static
OSErr SparkDaemonAESetEnabled(const AppleEvent *theAppleEvent, AppleEvent *reply, long handlerRefcon) {
  ShadowCTrace();
  return noErr;
}

@implementation SparkDaemon

/* Timer callback */
- (void)checkAndLoad:(id)sender {
  [SparkSharedLibrary() readLibrary:nil];
  DLog(@"Library loaded");
  [self checkActions];
  [self loadTriggers];
  DLog(@"Trigger registred");
}

- (id)init {
  if (self = [super init]) {
    if (![self openConnection]) {
      [self release];
      self = nil; 
    } else {
#if defined (DEBUG)
      [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
        @"YES", @"NSShowNonLocalizedStrings",
        //@"YES", @"NSShowAllViews",
        //SKFloat(0.15f), @"NSWindowResizeTime",
        //@"6", @"NSDragManagerLogLevel",
        //@"YES", @"NSShowNonLocalizableStrings",
        //@"1", @"NSScriptingDebugLogLevel",
        nil]];
#endif
      [NSApp setDelegate:self];
      /* Init core Apple Event handlers */
      AEInstallEventHandler(kCoreEventClass,
                            kAEQuitApplication,
                            NewAEEventHandlerUPP(SparkDaemonAEQuitHandler),
                            0, FALSE);
      
      AEInstallEventHandler('SprS',
                            'pEna',
                            NewAEEventHandlerUPP(SparkDaemonAESetEnabled),
                            0, FALSE);
      
      /* Send signal to editor */
      SDSendStateToEditor(kSparkDaemonStarted);
      
      int delay = 0;
      /* SparkDaemonDelay */
      ProcessSerialNumber psn = {kNoProcess, kCurrentProcess};
      CFDictionaryRef infos = ProcessInformationCopyDictionary(&psn, kProcessDictionaryIncludeAllInformationMask);
      if (infos) {
        CFNumberRef parent = CFDictionaryGetValue(infos, CFSTR("ParentPSN"));
        if (parent) {
          CFNumberGetValue(parent, kCFNumberLongLongType, &psn);
          
          /* If launch by something that is not Spark Editor */
          OSType sign = SKProcessGetSignature(&psn);
          if (sign != kSparkEditorHFSCreatorType) {
            CFNumberRef value = CFPreferencesCopyAppValue(CFSTR("SparkDaemonDelay"), (CFStringRef)kSparkBundleIdentifier);
            if (value) {
              CFNumberGetValue(value, kCFNumberIntType, &delay);
              CFRelease(value);
            }
          }
        }
        CFRelease(infos);
      }
      if (delay > 0) {
        DLog(@"Delay load: %i", delay);
        [NSTimer scheduledTimerWithTimeInterval:delay
                                         target:self
                                       selector:@selector(checkAndLoad:)
                                       userInfo:nil
                                        repeats:NO];
      } else {
        [self checkAndLoad:nil];
      }
      [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(willUpdateTrigger:)
                                                   name:kSparkLibraryWillUpdateObjectNotification
                                                 object:SparkSharedTriggerSet()];
      [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(willRemoveTrigger:)
                                                   name:kSparkLibraryWillRemoveObjectNotification
                                                 object:SparkSharedTriggerSet()];
    }
  }
  return self;
}

- (void)dealloc {
  [[NSConnection defaultConnection] invalidate];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

#pragma mark -
- (BOOL)isEnabled {
  return !sd_disabled;
}

- (void)setEnabled:(BOOL)enabled {
  if (XOR(!enabled, sd_disabled)) {
    sd_disabled = !enabled;
    if (sd_disabled)
      [self unloadTriggers];
    else
      [self loadTriggers];
  }
}

- (BOOL)openConnection {
  NSProtocolChecker *checker = [[NSProtocolChecker alloc] initWithTarget:self
                                                                protocol:@protocol(SparkServer)]; 
  NSConnection *connection = [NSConnection defaultConnection];
  [connection setRootObject:checker];
  [checker release];
  if (![connection registerName:kSparkConnectionName]) {
    DLog(@"Error While opening Connection");
    return NO;
  } else {
    DLog(@"Connection OK");
  }
  return YES;
}

- (void)checkActions {
  Boolean display = true;
  CFBooleanRef ref = CFPreferencesCopyAppValue(CFSTR("SDBlockAlertOnLoad"), (CFStringRef)kSparkBundleIdentifier);
  if (ref) {
    display = !CFBooleanGetValue(ref);
    CFRelease(ref);
  }
  /* Send actionDidLoad message to all actions */
  SparkAction *action;
  NSEnumerator *actions = [SparkSharedActionSet() objectEnumerator];
  NSMutableArray *errors = display ? [[NSMutableArray alloc] init] : nil;
  while (action = [actions nextObject]) {
    SparkAlert *alert = [action actionDidLoad];
    if (alert && display) {
      [alert setHideSparkButton:NO];
      [errors addObject:alert];
    }
  }
  /* Display errors of needed */
  if (display) {
    SparkDisplayAlerts(errors);
    [errors release];
  }
}

- (void)loadTriggers {
  SparkTrigger *trigger;
  NSEnumerator *triggers = [SparkSharedTriggerSet() objectEnumerator];
  while (trigger = [triggers nextObject]) {
    @try {
      [trigger setTarget:self];
      [trigger setAction:@selector(executeTrigger:)];
    } @catch (id exception) {
      SKLogException(exception);
    }
  }
  [self registerTriggers];
}

- (void)registerTriggers {
  SparkTrigger *trigger;
  SparkEntryManager *manager = SparkSharedManager();
  NSEnumerator *triggers = [SparkSharedTriggerSet() objectEnumerator];
  while (trigger = [triggers nextObject]) {
    @try {
      if (![trigger isRegistred]) {
        if ([manager containsActiveEntryForTrigger:[trigger uid]]) {
          [trigger setRegistred:YES];
        }
      } else {
        if (![manager containsActiveEntryForTrigger:[trigger uid]]) {
          [trigger setRegistred:NO];
        }
      }
    } @catch (id exception) {
      SKLogException(exception);
    }
  }
}

- (void)unloadTriggers {
  SparkTrigger *trigger;
  NSEnumerator *triggers = [SparkSharedTriggerSet() objectEnumerator];
  while (trigger = [triggers nextObject]) {
    @try {
      if ([trigger isRegistred]) {
        [trigger setRegistred:NO];
      }
    } @catch (id exception) {
      SKLogException(exception);
    }
  }
}

- (SparkApplication *)frontApplication {
  SparkApplication *front = nil;
  /* Try signature */
  OSType sign = SKProcessGetFrontProcessSignature();
  if (sign && kUnknownType != sign) {
    SparkApplication *app;
    NSEnumerator *apps = [SparkSharedApplicationSet() objectEnumerator];
    while (app = [apps nextObject]) {
      if ([app signature] == sign) {
        front = app;
        break;
      }
    }
  }
  /* Try bundle identifier */
  if (!front) {
    NSString *bundle = SKProcessGetFrontProcessBundleIdentifier();
    if (bundle) {
      SparkApplication *app;
      NSEnumerator *apps = [SparkSharedApplicationSet() objectEnumerator];
      while (app = [apps nextObject]) {
        if ([[app bundleIdentifier] isEqualToString:bundle]) {
          front = app;
          break;
        }
      }
    }
  }
  return front;
}

- (IBAction)executeTrigger:(SparkTrigger *)trigger {
  Boolean trapping;
  SparkAlert *alert = nil;
  DLog(@"Start handle event");
  /* If Spark Editor is trapping, forward keystroke */
  if ((noErr == SDGetEditorIsTrapping(&trapping)) && trapping) {
    [trigger bypass];
    return;
  }
  /* Warning: trigger can be release during it's own invocation, so retain it */
  [trigger retain];
  @try {
    BOOL status = YES;
    SparkAction *action = nil;
    /* If action depends front application */
    if ([trigger hasManyAction]) {      
      SparkApplication *front = [self frontApplication];
      if (front) {
        /* Get action for front application */
        action = [SparkSharedManager() actionForTrigger:[trigger uid] application:[front uid] isActive:&status];
      }
    }
    /* No action found, use default */
    if (!action) {
      action = [SparkSharedManager() actionForTrigger:[trigger uid] application:0 isActive:&status];
    }
    [trigger willTriggerAction:status ? action : nil];
    /* Action exists and is enabled */
    if (status && action) {
      alert = [action performAction];
    } else {
      [trigger bypass];
    }
    [trigger didTriggerAction:status ? action : nil];
  } @catch (id exception) {
    SKLogException(exception);
    NSBeep();
  }
  [trigger release];
  
  /* If alert not null */
  if (alert) {
    /* Check if need display alert */
    CFBooleanRef displayAlertRef = CFPreferencesCopyAppValue(CFSTR("SDDisplayAlertOnExecute"), (CFStringRef)kSparkBundleIdentifier);
    if (displayAlertRef) {
      if (CFBooleanGetValue(displayAlertRef))
        SparkDisplayAlert(alert);
      CFRelease(displayAlertRef);
    }
  }
  DLog(@"Finish handle event");
}

- (void)run {
  DLog(@"Waiting events");
  [NSApp run];
}

#pragma mark -
#pragma mark Application Delegate
- (void)applicationWillTerminate:(NSNotification *)aNotification {
  /* Invalidate connection. dealloc would probably not be called, so it is not a good candidate for this purpose */
  [[NSConnection defaultConnection] invalidate];
  [self unloadTriggers];
}

@end
