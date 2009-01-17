/*
 *  SparkPreferences.h
 *  SparkKit
 *
 *  Created by Grayfox on 14/04/07.
 *  Copyright 2007 Shadow Lab. All rights reserved.
 *
 */

#if !defined(__SPARK_PREFERENCES_H)
#define __SPARK_PREFERENCES_H 1

#if defined(__OBJC__)

#import <SparkKit/SparkKit.h>

enum {
  SparkPreferencesDaemon = 1,
  SparkPreferencesLibrary = 2,
  SparkPreferencesFramework = 3,
  /* plugins should only use this domain */
  SparkPreferencesPlugIn = SparkPreferencesLibrary,
};
typedef NSInteger SparkPreferencesDomain;

#pragma mark Preferences
SPARK_EXPORT
id SparkPreferencesGetValue(NSString *key, SparkPreferencesDomain domain);
SPARK_EXPORT
BOOL SparkPreferencesGetBooleanValue(NSString *key, SparkPreferencesDomain domain);
SPARK_EXPORT
NSInteger SparkPreferencesGetIntegerValue(NSString *key, SparkPreferencesDomain domain);

SPARK_EXPORT
void SparkPreferencesSetValue(NSString *key, id value, SparkPreferencesDomain domain);
SPARK_EXPORT
void SparkPreferencesSetBooleanValue(NSString *key, BOOL value, SparkPreferencesDomain domain);
SPARK_EXPORT
void SparkPreferencesSetIntegerValue(NSString *key, NSInteger value, SparkPreferencesDomain domain);

SPARK_EXPORT
Boolean SparkPreferencesSynchronize(SparkPreferencesDomain domain);

/* Library domain only */
SPARK_EXPORT
void SparkPreferencesRegisterObserver(id target, SEL callback, NSString *key, SparkPreferencesDomain domain);
SPARK_EXPORT
void SparkPreferencesUnregisterObserver(id target, NSString *key, SparkPreferencesDomain domain);

#endif /* __OBJC__ */

#endif /* __SPARK_PREFERENCES_H */
