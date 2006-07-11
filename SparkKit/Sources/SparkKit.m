/*
 *  SparkConstantes.c
 *  SparkKit
 *
 *  Created by Fox on 17/08/04.
 *  Copyright 2004 Shadow Lab. All rights reserved.
 *
 */

#import <SparkKit/SparkKit.h>

#if defined (DEBUG)
#warning Debug defined in SparkKit!
#endif

NSString * const kSparkFolderName = @"Spark";

NSString * const kSparkHFSCreator = @"Sprk";
NSString * const kSparkDaemonHFSCreator = @"SprS";
NSString * const kSparkBundleIdentifier = @"org.shadowlab.Spark";
NSString * const kSparkKitBundleIdentifier = @"org.shadowlab.SparkKit";
NSString * const kSparkDaemonBundleIdentifier = @"org.shadowlab.SparkDaemon";

const OSType kSparkHFSCreatorType = 'Sprk';
const OSType kSparkDaemonHFSCreatorType = 'SprS';