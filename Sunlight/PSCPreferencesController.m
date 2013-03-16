//
//  PSCPreferencesController.m
//  Sunlight
//
//  Created by Chloe Stars on 3/15/13.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "PSCPreferencesController.h"

@interface PSCPreferencesController ()

@end

@implementation PSCPreferencesController
@synthesize generalPreferences;
@synthesize accountsPreferences;
@synthesize servicesPreferences;
@synthesize notificationsPreferences;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

+ (NSString *)nibName
{
	return @"PSCPreferences";
}

- (void)setupToolbar
{
	[self addView:generalPreferences label:@"General"];
	[self addView:accountsPreferences label:@"Accounts"];
	[self addView:servicesPreferences label:@"Services"];
	[self addView:notificationsPreferences label:@"Notifications"];
}

@end
