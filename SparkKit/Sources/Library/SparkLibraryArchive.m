/*
 *  SparkLibraryArchive.m
 *  SparkKit
 *
 *  Created by Grayfox on 24/02/07.
 *  Copyright 2007 Shadow Lab. All rights reserved.
 */

#import <SparkKit/SparkLibraryArchive.h>
#import <SparkKit/SparkObjectSet.h>
#import <SparkKit/SparkPrivate.h>

#import "SparkIconManagerPrivate.h"

#import <SArchiveKit/SArchive.h>
#import <SArchiveKit/SArchiveFile.h>
#import <SArchiveKit/SArchiveDocument.h>

@interface SparkIconManager (SparkArchiveExtension)

- (void)readFromArchive:(SArchive *)archive path:(SArchiveFile *)path;
- (void)writeToArchive:(SArchive *)archive atPath:(SArchiveFile *)path;

@end

const OSType kSparkLibraryArchiveHFSType = 'SliX';
NSString * const kSparkLibraryArchiveExtension = @"splx";

static 
NSString * const kSparkLibraryArchiveFileName = @"Spark Library";

@implementation SparkLibrary (SparkArchiveExtension)

- (id)initFromArchiveAtPath:(NSString *)file {
  return [self initFromArchiveAtPath:file loadPreferences:YES];
}

- (id)initFromArchiveAtPath:(NSString *)file loadPreferences:(BOOL)flag {
  if (self = [self initWithPath:nil]) {
    SArchive *archive = [[SArchive alloc] initWithArchiveAtPath:file];
    
    SArchiveFile *library = [archive fileWithName:kSparkLibraryArchiveFileName];
    if (library) {
      NSFileWrapper *wrapper = [library fileWrapper];
      if (wrapper) {
        /* Init in memory icon manager */
        sp_icons = [[SparkIconManager alloc] initWithLibrary:self path:nil];
        /* Load library */
        [self readFromFileWrapper:wrapper error:nil];
        /* Load icons */
        SArchiveFile *icons = [archive fileWithName:@"Icons"];
        NSAssert(icons != nil, @"Invalid archive");
        [sp_icons readFromArchive:archive path:icons];
      }
    }
    [archive close];
    [archive release];
    
    /* just for test */
//    [sp_icons setPath:[@"~/Desktop/SparkIcons" stringByStandardizingPath]];
//    [self setPath:@"~/Desktop/SparkLibrary.splib"];
//    [self synchronize];
  }
  return self;
}

- (BOOL)archiveToFile:(NSString *)file {
  NSFileWrapper *wrapper = [self fileWrapper:nil];
  if (wrapper) {
    SArchive *archive = [[SArchive alloc] initWithArchiveAtPath:file write:YES];
    SArchiveDocument *doc = [archive addDocumentWithName:@"Spark"];
    CFStringRef str = CFUUIDCreateString(kCFAllocatorDefault, [self uuid]);
    if (str) {
      [doc setValue:(id)str forProperty:@"uuid"];
      CFRelease(str);
    }
    [doc setValue:[NSString stringWithFormat:@"%u", 1] forProperty:@"format"];
    [doc setValue:[NSString stringWithFormat:@"%u", kSparkLibraryCurrentVersion] forProperty:@"version"];
    
    [wrapper setFilename:kSparkLibraryArchiveFileName];
    [archive addFileWrapper:wrapper parent:nil];
    
    /* Save icons */
    if (sp_icons) {
      SArchiveFile *icons = [archive addFolder:@"Icons" properties:nil parent:nil];
      [sp_icons writeToArchive:archive atPath:icons];
    }
    
    [archive close];
    [archive release];
    return YES;
  }
  return NO;
}

@end

#pragma mark -
@implementation SparkIconManager (SparkArchiveExtension)

- (void)readFromArchive:(SArchive *)archive path:(SArchiveFile *)path {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  for (NSUInteger idx = 0; idx < 4; idx++) {
    /* Get Folder */
    SArchiveFile *folder = [path fileWithName:[NSString stringWithFormat:@"%u", idx]];
    
    SArchiveFile *file = nil;
    NSEnumerator *files = [[folder files] objectEnumerator];
    while (file = [files nextObject]) {
      NSData *data = [file extractContents];
      NSImage *icon = data ? [[NSImage alloc] initWithData:data] : nil;
      if (icon) {
        SparkObjectSet *set = _SparkObjectSetForType(sp_library, idx);
        SparkUID uid = [[file name] intValue];
        SparkObject *object = [set objectWithUID:uid];
        if (object) {
          _SparkIconEntry *entry = [self entryForObject:object];
          if (entry) {
            [entry setIcon:icon];
          }
        }
        [icon release];
      }
    }
  }
  [pool release];
}

- (void)writeToArchive:(SArchive *)archive atPath:(SArchiveFile *)path {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  for (NSUInteger idx = 0; idx < 4; idx++) {
    /* Create Folder */
    SArchiveFile *folder = [archive addFolder:[NSString stringWithFormat:@"%u", idx] properties:nil parent:path];
    
    NSMutableSet *blacklist = [[NSMutableSet alloc] init];
    [blacklist addObject:@".DS_Store"];
    /* Then, write in memory entries */
    SparkUID uid = 0;
    _SparkIconEntry *entry = nil;
    NSMapEnumerator items = NSEnumerateMapTable(sp_cache[idx]);
    while (NSNextMapEnumeratorPair(&items, (void **)&uid, (void **)&entry)) {
      /* If should save in memory entry */
      if ([entry hasChanged] || !sp_path) {
        NSString *strid = [NSString stringWithFormat:@"%u", uid];
        [blacklist addObject:strid];
        if ([entry icon]) {
          NSData *data = [[entry icon] TIFFRepresentationUsingCompression:NSTIFFCompressionLZW factor:1];
          if (data) {
            [archive addFile:strid data:data parent:folder];
          }
        }
      }
    }
    /* Finaly, archive on disk icons */
    if (sp_path) {
      NSString *fspath = [sp_path stringByAppendingPathComponent:[folder name]];
      NSArray *files = [[NSFileManager defaultManager] directoryContentsAtPath:fspath];
      NSUInteger count = [files count];
      while (count-- > 0) {
        NSString *fsicon = [files objectAtIndex:count];
        if (![blacklist containsObject:fsicon]) {
          NSString *fullpath = [fspath stringByAppendingPathComponent:fsicon];
          [archive addFile:fullpath name:fsicon parent:folder];
        }
      }
    }
    [blacklist release];
  }
  [pool release];
}

@end
