//
//  PSCPreferencesController.h
//  Sunlight
//
//  Created by Chloe Stars on 3/15/13.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "DBPrefsWindowController.h"

@interface PSCPreferencesController : DBPrefsWindowController

@property IBOutlet NSView *generalPreferences;
@property IBOutlet NSView *accountsPreferences;
@property IBOutlet NSView *servicesPreferences;
@property IBOutlet NSView *notificationsPreferences;

- (IBAction)openSharedDialog:(id)sender;

@end
