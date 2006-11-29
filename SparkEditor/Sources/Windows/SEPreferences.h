/*
 *  SEPreferences.h
 *  Spark Editor
 *
 *  Created by Grayfox on 07/09/06.
 *  Copyright 2006 Shadow Lab. All rights reserved.
 */

#import <ShadowKit/SKWindowController.h>

@interface SEPreferences : SKWindowController {
  @private
  IBOutlet NSOutlineView *ibPlugins;
  
  NSMutableArray *se_plugins;
}

@end
