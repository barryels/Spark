/*
 *  SparkPluginView.h
 *  SparkKit
 *
 *  Created by Black Moon Team.
 *  Copyright (c) 2004 - 2007 Shadow Lab. All rights reserved.
 */

#import WBHEADER(WBViewController.h)

@class SparkActionPlugIn;
@interface SparkPluginView : WBViewController {
  @private
	IBOutlet NSView *uiTrap;
  IBOutlet NSView *uiView;
  IBOutlet NSImageView *uiIcon;
  IBOutlet NSTextField *uiName;
}

- (void)setPlugin:(SparkActionPlugIn *)aPlugin;
- (void)setPluginView:(NSView *)aView;

- (NSView *)trapPlaceholder;

@end
