/*
 *  SparkApplication.h
 *  SparkKit
 *
 *  Created by Black Moon Team.
 *  Copyright (c) 2004 - 2007 Shadow Lab. All rights reserved.
 */

#import <SparkKit/SparkObject.h>

@class WBApplication;
WB_CLASS_EXPORT
@interface SparkApplication : SparkObject {
  @private
  struct _sp_appFlags {
    unsigned int disabled:1;
    unsigned int reserved:31;
  } sp_appFlags;
  WBApplication *sp_application;
}

+ (id)systemApplication;

- (id)initWithPath:(NSString *)path;

- (NSString *)path;
- (void)setPath:(NSString *)path;

- (OSType)signature;
- (NSString *)bundleIdentifier;

- (WBApplication *)application;

- (BOOL)isEnabled;
- (void)setEnabled:(BOOL)flag;

- (BOOL)isEditable;

@end

SPARK_EXPORT
NSString * const SparkApplicationDidChangeEnabledNotification;
