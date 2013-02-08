//
//  PSCLoginController.m
//  Sunlight
//
//  Created by Brady Valentino on 2013-02-07.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "PSCLoginController.h"

@interface PSCLoginController ()
    
@end

@implementation PSCLoginController
@synthesize cancelButton;
@synthesize titleView;
@synthesize usernameTextField;
@synthesize passwordTextField;

-(id)init
{
	if (![super initWithWindowNibName:@"PSCLogin"]) {
		return nil;
	}
	
	// Setup INAppStoreWindow custom window styling
	INAppStoreWindow *window = (INAppStoreWindow *)[self window];
	window.trafficLightButtonsLeftMargin = 7.0;
    window.fullScreenButtonRightMargin = 7.0;
    window.hideTitleBarInFullScreen = YES;
    window.centerFullScreenButton = YES;
    window.titleBarHeight = 30.0;
    window.centerTrafficLightButtons = NO;
    window.titleBarStartColor = [NSColor colorWithDeviceRed:0.945 green:0.945 blue:0.945 alpha:1.0];
    window.titleBarEndColor = [NSColor colorWithDeviceRed:0.945 green:0.945 blue:0.945 alpha:1.0];
    window.inactiveTitleBarStartColor = [NSColor colorWithDeviceRed:0.945 green:0.945 blue:0.945 alpha:1.0];
    window.inactiveTitleBarEndColor = [NSColor colorWithDeviceRed:0.945 green:0.945 blue:0.945 alpha:1.0];
    window.showsBaselineSeparator = NO;
    
    // Custom titleView as defined in IB
    self.titleView.frame = window.titleBarView.bounds;
    self.titleView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [window.titleBarView addSubview:titleView];
	
	return self;
    
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    NSColor *topColor = [NSColor colorWithDeviceRed:0.945 green:0.945 blue:0.945 alpha:1.0];
	NSColor *bottomColor = [NSColor colorWithDeviceRed:0.867 green:0.867 blue:0.867 alpha:1.0];
	[loginGradientView setStartingColor:topColor];
	[loginGradientView setEndingColor:bottomColor];
	
}

- (IBAction)pressCancel:(id)sender {
	[self close];
	//[[self window] close];
}

- (IBAction)signIn:(id)sender
{
	
}

@end