//
//  PSCLoginController.m
//  Sunlight
//
//  Created by Brady Valentino on 2013-02-07.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "PSCLoginController.h"
#import "AppNetKit.h"
#import "PSCMemoryCache.h"

@interface PSCLoginController ()
    
@end

@implementation PSCLoginController
@synthesize cancelButton;
@synthesize titleView;
@synthesize usernameTextField;
@synthesize passwordTextField;
@synthesize progressIndicator;
@synthesize successCallback;

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
    
    [window center];
	
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
	[loginGradientView setStartingColor:topColor endingColor:bottomColor];
	
}

- (IBAction)pressCancel:(id)sender
{
	if (![PSCMemoryCache sharedMemory].authToken) {
		[[NSApplication sharedApplication] terminate:self];
	}
	else {
		[[self window] close];
	}
}

static int numberOfShakes = 8;
static float durationOfShake = 0.5f;
static float vigourOfShake = 0.05f;

- (CAKeyframeAnimation *)shakeAnimation:(NSRect)frame
{
    CAKeyframeAnimation *shakeAnimation = [CAKeyframeAnimation animation];
	
    CGMutablePathRef shakePath = CGPathCreateMutable();
    CGPathMoveToPoint(shakePath, NULL, NSMinX(frame), NSMinY(frame));
	int index;
	for (index = 0; index < numberOfShakes; ++index)
	{
		CGPathAddLineToPoint(shakePath, NULL, NSMinX(frame) - frame.size.width * vigourOfShake, NSMinY(frame));
		CGPathAddLineToPoint(shakePath, NULL, NSMinX(frame) + frame.size.width * vigourOfShake, NSMinY(frame));
	}
    CGPathCloseSubpath(shakePath);
    shakeAnimation.path = shakePath;
    shakeAnimation.duration = durationOfShake;
    return shakeAnimation;
}

- (IBAction)signIn:(id)sender
{
	[progressIndicator startAnimation:nil];
	// begin white list
	BOOL allowed = NO;
	NSArray *whitelist = @[@"codinguru",
						@"bradyv",
						@"jwisser",
                        @"sulgi",
						@"preshit",
						@"dalton",
						@"aah",
						@"joeldev",
						@"tandyq",
						@"jamesabeth",
						@"jakepolo",
						@"asmallteapot",
						@"jdhartley",
						@"ryangould"
						@"iamsebj",
						@"kolin",
						@"failgunner",
						@"colby",
						@"black",
						@"hrbrt",
						@"christian",
                        @"starring",
                        @"stevestreza"];
	for (NSString *username in whitelist) {
		if ([usernameTextField.stringValue isEqualToString:username]) {
			allowed = YES;
		}
	}
	if (!allowed) {
		[progressIndicator stopAnimation:nil];
		[[self window] setAnimations:@{@"frameOrigin":[self shakeAnimation:[self.window frame]]}];
		[[self.window animator] setFrameOrigin:[self.window frame].origin];
		return;
	}
	// end white list
	[ANAuthenticator.sharedAuthenticator accessTokenForScopes:@[ ANScopeStream, ANScopeEmail, ANScopeWritePost, ANScopeFollow, ANScopeMessages ] withUsername:usernameTextField.stringValue password:passwordTextField.stringValue completion:^(NSString * accessToken, id rep, NSError * error) {
        [progressIndicator stopAnimation:nil];
        
        if(!accessToken) {
            //[self showErrorToUser:error];
			[[self window] setAnimations:@{@"frameOrigin":[self shakeAnimation:[self.window frame]]}];
			[[self.window animator] setFrameOrigin:[self.window frame].origin];
            return;
        }
        
		[PSCMemoryCache sharedMemory].authToken = accessToken;
		[[self window] close];
		[NSApp abortModal];
		successCallback();
		successCallback = nil;
    }];
}

@end