//
//  PSCPreferencesController.h
//  Sunlight
//
//  Created by Chloe Stars on 3/15/13.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "DBPrefsWindowController.h"
#import "InstapaperKit.h"
#import "PSCUploader.h"
#import "PSCReadLater.h"

@interface PSCPreferencesController : DBPrefsWindowController <IKEngineDelegate>
{
	PSCUploader *uploader;
	PSCReadLater *readLater;
}

@property IBOutlet NSView *generalPreferences;
@property IBOutlet NSView *accountsPreferences;
@property IBOutlet NSView *servicesPreferences;
@property IBOutlet NSView *notificationsPreferences;
@property IBOutlet NSWindow *loginWindow;
@property IBOutlet NSWindow *loggedInWindow;
@property IBOutlet NSTextField *loginTextLabel;
@property IBOutlet NSTextField *usernameTextField;
@property IBOutlet NSTextField *passwordTextField;
@property IBOutlet NSTextField *serviceLabel;
@property IBOutlet NSTextField *loggedInLabel;

@end
