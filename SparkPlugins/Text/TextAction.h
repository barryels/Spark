/*
 *  TextAction.h
 *  Spark Plugins
 *
 *  Created by Black Moon Team.
 *  Copyright (c) 2004 - 2007, Shadow Lab. All rights reserved.
 */

#import <SparkKit/SparkPlugInAPI.h>

WB_PRIVATE
NSString * const kKeyboardActionBundleIdentifier;

#define kKeyboardActionBundle		[NSBundle bundleWithIdentifier:kKeyboardActionBundleIdentifier]

WB_INLINE
bool TADateFormatterCustomFormat(NSInteger format) {
  return (format & 0xffff) == 0;
}

WB_INLINE
CFDateFormatterStyle TADateFormatterStyle(NSInteger format) {
  return format & 0xff;
}
WB_INLINE 
NSInteger TASetDateFormatterStyle(NSInteger format, CFDateFormatterStyle style) {
  format &= ~0xff;
  return format | style;
}

WB_INLINE
CFDateFormatterStyle TATimeFormatterStyle(NSInteger format) {
  return (format >> 8) & 0xff;
}
WB_INLINE 
NSInteger TASetTimeFormatterStyle(NSInteger format, CFDateFormatterStyle style) {
  format &= ~0xff00;
  return format | (style << 8);
}

enum KeyboardActionType {
  kTATextAction      = 'Text',
  kTADateStyleAction = 'DSty',
  kTADateFormatAction = 'DFmt',
  kTAKeystrokeAction = 'Keys',
};
typedef OSType KeyboardActionType;

@interface TextAction : SparkAction {
  id ta_data;
	BOOL ta_repeat;
  BOOL ta_locked;
  useconds_t ta_latency;
  KeyboardActionType ta_type;
}

- (id)data;
- (void)setData:(id)anObject;

- (useconds_t)latency;
- (void)setLatency:(useconds_t)latency;

- (BOOL)autorepeat;
- (void)setAutorepeat:(BOOL)flag;

- (KeyboardActionType)action;
- (void)setAction:(KeyboardActionType)action;

- (id)serializedData;
- (void)setSerializedData:(id)data;

@end

