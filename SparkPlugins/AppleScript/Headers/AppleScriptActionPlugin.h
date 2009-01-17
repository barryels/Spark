/*
 *  AppleScriptActionPlugin.h
 *  Spark Plugins
 *
 *  Created by Black Moon Team.
 *  Copyright (c) 2004 - 2007, Shadow Lab. All rights reserved.
 */

#import <SparkKit/SparkPlugInAPI.h>

@class OSAScript, OSAScriptController;
@interface AppleScriptActionPlugin : SparkActionPlugIn {
  IBOutlet OSAScriptController *ibScriptController;
  @private
    NSString *as_file;
  int as_tidx;
}

- (IBAction)open:(id)sender;
- (IBAction)import:(id)sender;

- (IBAction)launchEditor:(id)sender;

- (NSString *)scriptFile;
- (void)setScriptFile:(NSString *)aFile;

- (int)selectedTab;
- (void)setSelectedTab:(int)tab;

- (NSAlert *)compileScript:(OSAScript *)script;

@end
