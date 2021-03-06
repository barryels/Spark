/*
 *  SparkActionPlugIn.h
 *  SparkKit
 *
 *  Created by Black Moon Team.
 *  Copyright (c) 2004 - 2007 Shadow Lab. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

#import <SparkKit/SparkDefine.h>

@class SparkAction;

/*!
 @abstract This class is the base class to do a Spark PlugIn. If you want to add some kind of Action to Spark,
 you will use a subclass of SparkActionPlugIn.
 @discussion This is an Abstract class, so it can't be instanciated. Some methode must be implemented by subclass.
 If you use this class in IB, you can define an Outlet with name actionView.
 */
SPARK_OBJC_EXPORT
@interface SparkActionPlugIn : NSViewController

/*!
 @abstract This methode is call when an action editor is opened. The base implementation try to
 open the Main Nib File of the bundle and return the view attache to the <i>actionView</i> IBOutlet.
 @discussion You normally don't override this method. Just set the main nib File in the plist Bundle.
 Set the owner of this nib file on this class, and set <code>actionView</code> IBOutlet on the customView you want to use.
 @result The <code>NSView</code> that will be displayed in Spark.
 */
@property (nonatomic, readonly) NSView *actionView;

/*!
	@method
 @param isEditing YES if editing an existing action, NO if <code>anAction</code> is a new instance.
 @abstract The default implementation do nothing.
 @discussion Methode called when an plugin action editor is loaded.
 */
- (void)loadSparkAction:(SparkAction *)anAction toEdit:(BOOL)isEditing;


/*!
	@method
 @abstract Default implementation does nothing and returns nil.
 @discussion Methode call just before the editor will close and create or update an Action.
 You should verify infos needed to create action and if infos are missing or
 are not valid, you can return an NSAlert that will be displayed.
 @result An alert you want display to the user or nil if all fields are OK.
 */
- (NSAlert *)sparkEditorShouldConfigureAction;

/*!
	@method
 @abstract Default implementation does nothing.
 @discussion <strong>Required!</strong> This methode must configure the Action.
 <code>configureAction</code> is called when user want to create an Action. In this methode you must
 set all require parameters of your Action (including name, icon, and description).
 Spark call <code>-configureAction</code> only if <code>-sparkEditorShouldConfigureAction</code> returned nil.
 */
- (void)configureAction;

/*!
 @abstract Returns the action currently edited by the receiver.
 */
@property(nonatomic, retain, readonly) __kindof SparkAction *sparkAction;

// MARK: Hook entry points
/* Those methods does nothing. Subclasses can override those methods to perform whatever actions are necessary. */
- (void)plugInViewWillBecomeVisible;
- (void)plugInViewDidBecomeVisible;

- (void)plugInViewWillBecomeHidden;
- (void)plugInViewDidBecomeHidden;

// MARK: -
// MARK: Advanced
/*!
 @discussion This function can be used to choose to display or hide some settings
 in action configuration panels.
 @result Returns YES if user has enabled advanced settings.
 */
@property(nonatomic, readonly) BOOL displaysAdvancedSettings;

/*!
 @discussion The default -actionView is composed using 'plugin full name', 'plugin view icon', the hotkey field
 and the plugin nib view. If your plugin use a custom layout, you have to:
 - Override -hasCustomView to return YES, so the -actionView will return your nib view instead of
 the default view.
 - Override -awakeFromNib to call -setHotKeyTrapPlaceholder: with your trap placeholder view.
 @result Return YES if this plugin use a custom view and do not want to use the default view layout.
 */
@property(nonatomic, readonly) BOOL hasCustomView;

/*!
 @method
 @param placeholder A simple NSView that will be replaced by the Shortcut editor field.
 */
- (void)setHotKeyTrapPlaceholder:(NSView *)placeholder;

@end

@interface SparkActionPlugIn (SparkDynamicPlugIn)

/* NSMainNibFile */
+ (NSString *)nibName;

/* SparkActionClass */
+ (Class)actionClass;

/* SparkPluginName */
+ (NSString *)plugInName;

/* SparkPluginIcon */
+ (NSImage *)plugInIcon;

/* SparkHelpFile */
+ (NSURL *)helpURL;

/* Plugin View support */
/*!
 @result Returns "'plugInName' Action" by default.
 */
+ (NSString *)plugInFullName;
/*!
 @result Returns the plugin icon. You can use a multi size icon file.
 */
+ (NSImage *)plugInViewIcon;

@end
