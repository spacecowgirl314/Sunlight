//
//  PSCPreferencesController.m
//  Sunlight
//
//  Created by Chloe Stars on 3/15/13.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "PSCPreferencesController.h"
#import "PocketAPI.h"

@interface PSCPreferencesController ()

@end

@implementation PSCPreferencesController
@synthesize generalPreferences;
@synthesize accountsPreferences;
@synthesize servicesPreferences;
@synthesize notificationsPreferences;
@synthesize loginWindow;
@synthesize loginTextLabel;
@synthesize usernameTextField;
@synthesize passwordTextField;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
		[[NSUserDefaultsController sharedUserDefaultsController] addObserver:self
																  forKeyPath:@"values.readLaterService"
																	 options:NSKeyValueObservingOptionNew
																	 context:NULL];
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
	[self addView:generalPreferences label:@"General" image:[NSImage imageNamed:@"prefs-general"]];
	[self addView:accountsPreferences label:@"Accounts" image:[NSImage imageNamed:@"prefs-accounts"]];
	[self addView:servicesPreferences label:@"Services" image:[NSImage imageNamed:@"prefs-services"]];
	[self addView:notificationsPreferences label:@"Notifications" image:[NSImage imageNamed:@"prefs-notifications"]];
}

- (IBAction)changeReadLater:(id)sender
{
	NSPopUpButton *popUpButton = sender;
	NSInteger readLater = [popUpButton indexOfSelectedItem];
	switch (readLater) {
		case 0:
			break;
		case 1:
			[self setupLoginSheet];
			[NSApp beginSheet: loginWindow
			   modalForWindow: self.window
				modalDelegate: self
			   didEndSelector: nil //@selector(saveSheetDidEnd:returnCode:contextInfo:)
				  contextInfo: NULL];
			/*[[PocketAPI sharedAPI] loginWithHandler:^(PocketAPI *api, NSError *error) {
			 if (!error) {
			 NSLog(@"Pocket logged in successfully");
			 }
			 else {
			 NSLog(@"Pocket login failed.");
			 }
			 }];*/
			break;
		case 2:
			[self setupLoginSheet];
			[NSApp beginSheet: loginWindow
			   modalForWindow: self.window
				modalDelegate: self
			   didEndSelector: nil //@selector(saveSheetDidEnd:returnCode:contextInfo:)
				  contextInfo: NULL];
			break;
	}
}

-(void)observeValueForKeyPath:(NSString *)keyPath
					 ofObject:(id)object
					   change:(NSDictionary *)change
					  context:(void *)context
{
    NSLog(@"KVO: %@ changed property %@ to value %@", object, keyPath, change);
	NSString *newKeyPath = [keyPath stringByReplacingOccurrencesOfString:@"values." withString:@""];
	if ([newKeyPath isEqualToString:@"readLaterService"]) {
		// Get font preferences
		NSNumber *readLaterServiceIndexNumber = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"readLaterService"];
		switch ([readLaterServiceIndexNumber integerValue]) {
			case 0:
				break;
			case 1:
				break;
			case 2:
				break;
		}
	}
}

#pragma mark - Login Sheet

- (PSCShareService)currentService
{
	NSNumber *readLaterServiceIndexNumber = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"readLaterService"];
	switch ([readLaterServiceIndexNumber integerValue]) {
		case 1:
			return PSCShareServicePocket;
			break;
		case 2:
			return PSCShareServiceInstapaper;
			break;
	}
	return PSCShareServiceReadingList;
}

- (void)setupLoginSheet
{
	NSNumber *readLaterServiceIndexNumber = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"readLaterService"];
	switch ([readLaterServiceIndexNumber integerValue]) {
		case 1:
			[loginTextLabel setStringValue:@"Log into Pocket"];
			break;
		case 2:
			[loginTextLabel setStringValue:@"Log into Instapaper"];
			break;
	}
}

- (IBAction)closeLoginSheet:(id)sender
{
	[loginWindow close];
	[NSApp endSheet:loginWindow returnCode:NSCancelButton];
}

- (IBAction)submitLoginInformation:(id)sender
{
	if ([self currentService]==PSCShareServiceInstapaper) {
		// Assuming that your class has an instance variable _engine
		IKEngine *engine = [[IKEngine alloc] initWithDelegate:self];
		[engine authTokenForUsername:[usernameTextField stringValue] password:[passwordTextField stringValue] userInfo:nil];
	}
	//[loginWindow close];
	//[NSApp endSheet:loginWindow returnCode:NSOKButton];
}

#pragma IKEngine Delegate

- (void)engine:(IKEngine *)engine connection:(IKURLConnection *)connection didReceiveAuthToken:(NSString *)token andTokenSecret:(NSString *)secret
{
	NSLog(@"Instapaper login worked");
    // Assign token and secret
    engine.OAuthToken  = token;
    engine.OAuthTokenSecret = secret;
	
	[[NSUserDefaults standardUserDefaults] setObject:token forKey:@"InstapaperOAuthToken"];
	[[NSUserDefaults standardUserDefaults] setObject:secret forKey:@"InstapaperOAuthTokenSecret"];
	
	[loginWindow close];
	[NSApp endSheet:loginWindow returnCode:NSOKButton];
	
    // Save token and secret in keychain (do not use NSUserDefaults for the secret!)
}

- (void)engine:(IKEngine *)engine didFailConnection:(IKURLConnection *)connection error:(NSError *)error
{
	NSLog(@"Instapaper login failed");
}

@end
