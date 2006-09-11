/*
 *  SparkEntry.m
 *  SparkKit
 *
 *  Created by Black Moon Team.
 *  Copyright (c) 2004 - 2006 Shadow Lab. All rights reserved.
 */

#import <SparkKit/SparkEntry.h>
#import <SparkKit/SparkAction.h>

@implementation SparkEntry

- (id)copyWithZone:(NSZone *)aZone {
  SparkEntry *copy = (SparkEntry *)NSCopyObject(self, 0, aZone);
  [copy->sp_action retain];
  [copy->sp_trigger retain];
  [copy->sp_application retain];
  return copy;
}

+ (id)entryWithAction:(SparkAction *)anAction trigger:(SparkTrigger *)aTrigger application:(SparkApplication *)anApplication {
  return [[[self alloc] initWithAction:anAction trigger:aTrigger application:anApplication] autorelease];
}

- (id)initWithAction:(SparkAction *)anAction trigger:(SparkTrigger *)aTrigger application:(SparkApplication *)anApplication {
  if (self = [super init]) {
    [self setAction:anAction];
    [self setTrigger:aTrigger];
    [self setApplication:anApplication];
  }
  return self;
}

- (void)dealloc {
  [sp_action release];
  [sp_trigger release];
  [sp_application release];
  [super dealloc];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"{ Trigger: %@, Action: %@ }", sp_trigger, sp_action];
}

- (BOOL)isEqualToEntry:(SparkEntry *)anEntry {
  return
  [sp_action uid] == [[anEntry action] uid] &&
  [sp_trigger uid] == [[anEntry trigger] uid] &&
  [sp_application uid] == [[anEntry application] uid];
}

#pragma mark -
- (SparkAction *)action {
  return sp_action;
}
- (void)setAction:(SparkAction *)action {
  SKSetterRetain(sp_action, action);
}

- (id)trigger {
  return sp_trigger;
}
- (void)setTrigger:(SparkTrigger *)trigger {
  SKSetterRetain(sp_trigger, trigger);
}

- (SparkApplication *)application {
  return sp_application;
}
- (void)setApplication:(SparkApplication *)anApplication {
  SKSetterRetain(sp_application, anApplication);
}

- (SparkEntryType)type {
  return sp_seFlags.type;
}
- (void)setType:(SparkEntryType)type {
  sp_seFlags.type = type;
}

- (BOOL)isEnabled {
  return sp_seFlags.enabled;
}
- (void)setEnabled:(BOOL)enabled {
  SKSetFlag(sp_seFlags.enabled, enabled);
}

- (NSImage *)icon {
  return [sp_action icon];
}
- (void)setIcon:(NSImage *)anIcon {
  [sp_action setIcon:anIcon];
}

- (NSString *)name {
  return [sp_action name];
}
- (void)setName:(NSString *)aName {
  [sp_action setName:aName];
}

- (NSString *)categorie {
  return [sp_action categorie];
}
- (NSString *)actionDescription {
  return [sp_action actionDescription];
}
- (NSString *)triggerDescription {
  return [sp_trigger triggerDescription];
}

@end