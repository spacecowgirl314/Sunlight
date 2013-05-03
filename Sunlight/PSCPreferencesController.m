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
@synthesize loggedInWindow;
@synthesize loginTextLabel;
@synthesize usernameTextField;
@synthesize passwordTextField;
@synthesize serviceLabel;
@synthesize loggedInLabel;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
		[[NSUserDefaultsController sharedUserDefaultsController] addObserver:self
																  forKeyPath:@"values.readLaterService"
																	 options:NSKeyValueObservingOptionNew
																	 context:NULL];
		readLater = [PSCReadLater new];
		uploader = [PSCUploader new];
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
	//NSInteger readLater = [popUpButton indexOfSelectedItem];
	switch ([readLater currentService]) {
		case PSCReadLaterServiceReadingList:
			break;
		case PSCReadLaterServicePocket: {
			if ([[PocketAPI sharedAPI] isLoggedIn]) {
				[self setupLoggedInSheet];
				[NSApp beginSheet: loggedInWindow
				   modalForWindow: self.window
					modalDelegate: self
				   didEndSelector: nil //@selector(saveSheetDidEnd:returnCode:contextInfo:)
					  contextInfo: NULL];
			}
			else {
				/*[self setupLoginSheet];
				[NSApp beginSheet: loginWindow
				   modalForWindow: self.window
					modalDelegate: self
				   didEndSelector: nil //@selector(saveSheetDidEnd:returnCode:contextInfo:)
					  contextInfo: NULL];*/
				[[PocketAPI sharedAPI] loginWithHandler: ^(PocketAPI *API, NSError *error){
					if (error != nil)
					{
						// There was an error when authorizing the user. The most common error is that the user denied access to your application.
						// The error object will contain a human readable error message that you should display to the user
						// Ex: Show an UIAlertView with the message from error.localizedDescription
						[popUpButton selectItemAtIndex:0];
					}
					else
					{
						// The user logged in successfully, your app can now make requests.
						// [API username] will return the logged-in user’s username and API.loggedIn will == YES
					}
				}];
			}
			break;
		}
		case PSCReadLaterServiceInstapaper:
			if ([[NSUserDefaults standardUserDefaults] objectForKey:@"InstapaperOAuthTokenSecret"]) {
				[self setupLoggedInSheet];
				[NSApp beginSheet: loggedInWindow
				   modalForWindow: self.window
					modalDelegate: self
				   didEndSelector: nil //@selector(saveSheetDidEnd:returnCode:contextInfo:)
					  contextInfo: NULL];
			}
			else {
				[self setupLoginSheet:YES];
				[NSApp beginSheet: loginWindow
				   modalForWindow: self.window
					modalDelegate: self
				   didEndSelector: nil //@selector(saveSheetDidEnd:returnCode:contextInfo:)
					  contextInfo: NULL];
			}
			break;
	}
}

- (IBAction)changeUpload:(id)sender
{
	NSPopUpButton *popUpButton = sender;
	PSCUploadService uploadService = (int)[popUpButton indexOfSelectedItem];
	switch (uploadService) {
		case PSCUploadServiceCloud:
		{
			[self setupLoginSheet:NO];
			[NSApp beginSheet: loginWindow
			   modalForWindow: self.window
				modalDelegate: self
			   didEndSelector: nil //@selector(saveSheetDidEnd:returnCode:contextInfo:)
				  contextInfo: NULL];
			break;
		}
		case PSCUploadServiceDroplr:
		{
			[self setupLoginSheet:NO];
			[NSApp beginSheet: loginWindow
			   modalForWindow: self.window
				modalDelegate: self
			   didEndSelector: nil //@selector(saveSheetDidEnd:returnCode:contextInfo:)
				  contextInfo: NULL];
		}
		default:
			break;
	}
}

- (IBAction)changeAccount:(id)sender
{
	switch ([readLater currentService]) {
		case PSCReadLaterServicePocket: {
			[[PocketAPI sharedAPI] logout];
			[[NSUserDefaults standardUserDefaults] synchronize];
			[[PocketAPI sharedAPI] loginWithHandler: ^(PocketAPI *API, NSError *error){
				if (error != nil)
				{
					// There was an error when authorizing the user. The most common error is that the user denied access to your application.
					// The error object will contain a human readable error message that you should display to the user
					// Ex: Show an UIAlertView with the message from error.localizedDescription
					
					// fail silently?
				}
				else
				{
					// The user logged in successfully, your app can now make requests.
					// [API username] will return the logged-in user’s username and API.loggedIn will == YES
				}
			}];
			break;
		}
		default: {
			[loggedInWindow close];
			[NSApp endSheet:loggedInWindow returnCode:NSCancelButton];
			[self setupLoginSheet:YES];
			[NSApp beginSheet: loginWindow
			   modalForWindow: self.window
				modalDelegate: self
			   didEndSelector: nil //@selector(saveSheetDidEnd:returnCode:contextInfo:)
				  contextInfo: NULL];
			break;
		}
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

#pragma mark - Logged In Sheet

- (void)setupLoggedInSheet
{
	switch ([readLater currentService]) {
		case PSCReadLaterServiceReadingList:
			break;
		case PSCReadLaterServiceInstapaper: {
			[serviceLabel setStringValue:@"Instapaper"];
			IKEngine *engine = [[IKEngine alloc] initWithDelegate:self];
			engine.OAuthToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"InstapaperOAuthToken"];
			engine.OAuthTokenSecret = [[NSUserDefaults standardUserDefaults] stringForKey:@"InstapaperOAuthTokenSecret"];
			[engine verifyCredentialsWithUserInfo:nil];
			break;
		}
		case PSCReadLaterServicePocket: {
			[serviceLabel setStringValue:@"Pocket"];
			[loggedInLabel setStringValue:[[NSString alloc] initWithFormat:@"You are logged in as \"%@\".", [[PocketAPI sharedAPI] username]]];
			break;
		}
	}
}

#pragma mark - Login Sheet

- (void)setupLoginSheet:(BOOL)isReadLater
{
	if (isReadLater) {
		switch ([readLater currentService]) {
			case PSCReadLaterServiceReadingList:
			case PSCReadLaterServicePocket:
				[loginTextLabel setStringValue:@"Log into Pocket"];
				break;
			case PSCReadLaterServiceInstapaper:
				[loginTextLabel setStringValue:@"Log into Instapaper"];
				break;
		}
	}
	else {
		switch ([uploader currentService]) {
			case PSCUploadServiceCloud:
				[loginTextLabel setStringValue:@"Log into Cloud"];
				break;
			case PSCUploadServiceDroplr:
				[loginTextLabel setStringValue:@"Log into Droplr"];
				break;
			default:
				break;
		}
	}
}

- (IBAction)closeLoginSheet:(id)sender
{
	[loginWindow close];
	[NSApp endSheet:loginWindow returnCode:NSCancelButton];
}

- (IBAction)closeLoggedInSheet:(id)sender
{
	[loggedInWindow close];
	[NSApp endSheet:loggedInWindow returnCode:NSCancelButton];
}

- (IBAction)submitLoginInformation:(id)sender
{
	// need a way to determine whether we submitted for read later or uploader
	if ([readLater currentService]==PSCReadLaterServiceInstapaper) {
		// Assuming that your class has an instance variable _engine
		IKEngine *engine = [[IKEngine alloc] initWithDelegate:self];
		[engine authTokenForUsername:[usernameTextField stringValue] password:[passwordTextField stringValue] userInfo:nil];
	}
	if ([uploader currentService]==PSCUploadServiceCloud)
	{
		[[NSUserDefaults standardUserDefaults] setObject:[usernameTextField stringValue] forKey:@"cloudEmail"];
		[[NSUserDefaults standardUserDefaults] setObject:[passwordTextField stringValue] forKey:@"cloudPassword"];
	}
	if ([uploader currentService]==PSCUploadServiceDroplr)
	{
		[[NSUserDefaults standardUserDefaults] setObject:[usernameTextField stringValue] forKey:@"droplrEmail"];
		[[NSUserDefaults standardUserDefaults] setObject:DKHashPassword([passwordTextField stringValue]) forKey:@"droplrPassword"];
	}
	[loginWindow close];
	[NSApp endSheet:loginWindow returnCode:NSOKButton];
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

- (void)engine:(IKEngine *)engine connection:(IKURLConnection *)connection didVerifyCredentialsForUser:(IKUser *)user
{
	[loggedInLabel setStringValue:[[NSString alloc] initWithFormat:@"You are logged in as \"%@\".", [user username]]];
}

@end
