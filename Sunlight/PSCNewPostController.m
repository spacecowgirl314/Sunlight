//
//  PSCNewPostWindowController.m
//  Sunlight
//
//  Created by Chloe Stars on 10/12/12.
//  Copyright (c) 2012 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "PSCNewPostController.h"
#import "PSCMemoryCache.h"
#import "PSCUploader.h"

@interface PSCNewPostController ()

@end

@implementation PSCNewPostController
@synthesize postTextField, charactersLeftLabel;
@synthesize postButton, bottomGradientView;
@synthesize topGradientView, cancelButton;
@synthesize avatarView;
@synthesize titleView;
@synthesize postTextView;

-(id)init
{
	if (![super initWithWindowNibName:@"PSCNewPost"]) {
		return nil;
	}
	
	// Setup INAppStoreWindow custom window styling
	INAppStoreWindow *window = (INAppStoreWindow *)[self window];
	window.trafficLightButtonsLeftMargin = 7.0;
    window.fullScreenButtonRightMargin = 7.0;
    window.hideTitleBarInFullScreen = YES;
    window.centerFullScreenButton = YES;
    window.titleBarHeight = 5.0;
    window.centerTrafficLightButtons = NO;
    window.titleBarStartColor = [NSColor colorWithDeviceRed:0.98 green:0.98 blue:0.98 alpha:1.0];
    window.titleBarEndColor = [NSColor colorWithDeviceRed:0.98 green:0.98 blue:0.98 alpha:1.0];
    window.inactiveTitleBarStartColor = [NSColor colorWithDeviceRed:0.98 green:0.98 blue:0.98 alpha:1.0];
    window.inactiveTitleBarEndColor = [NSColor colorWithDeviceRed:0.98 green:0.98 blue:0.98 alpha:1.0];
    window.showsBaselineSeparator = NO;
    
    [window center];
	
	[postTextView setDelegate:self];
	uploader = [PSCUploader new];
	
	return self;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowWillLoad
{
	// load up the avatar
	[ANSession.defaultSession userWithID:ANMeUserID completion:^(ANResponse *response, ANUser *user, NSError *error) {
		if ([[PSCMemoryCache sharedMemory].avatarImages objectForKey:[user username]])
		{
			[[self avatarView] setImage:[[PSCMemoryCache sharedMemory].avatarImages objectForKey:[user username]]];
		}
		else {
			[[user avatarImage] imageAtSize:CGSizeMake(52*2, 52*2) completion:^(NSImage *image, NSError *error) {
				NSImage *maskedImage = [[PSCMemoryCache sharedMemory] maskImage:image withMask:[NSImage imageNamed:@"avatar-mask"]];
				[[PSCMemoryCache sharedMemory].avatarImages setValue:maskedImage forKey:[user username]];
				[[self avatarView] setImage:maskedImage];
			}];
		}
	}];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
	
	NSColor *topColor = [NSColor colorWithDeviceRed:0.208 green:0.208 blue:0.208 alpha:1.0];
	NSColor *bottomColor = [NSColor colorWithDeviceRed:0.094 green:0.094 blue:0.094 alpha:1.0];
	[bottomGradientView setStartingColor:topColor endingColor:bottomColor];
	
	topColor = [NSColor colorWithDeviceRed:0.98 green:0.98 blue:0.98 alpha:1.0];
	bottomColor = [NSColor colorWithDeviceRed:0.831 green:0.831 blue:0.831 alpha:1.0];
	[topGradientView setStartingColor:topColor endingColor:bottomColor];
	
	/*topColor = [NSColor colorWithDeviceRed:0.435 green:0.635 blue:0.878 alpha:1.0];
	bottomColor = [NSColor colorWithDeviceRed:0.141 green:0.357 blue:0.741 alpha:1.0];
	[postButton setStartingColor:topColor];
	[postButton setEndingColor:bottomColor];*/
	
	//[postTextView setDelegate:self];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:NSTextDidChangeNotification object:nil];
}

- (IBAction)pressCancel:(id)sender
{
	[postTextView setString:@""];
	[charactersLeftLabel setIntegerValue:256];
	[[self window] close];
}

// From http://developer.apple.com/library/mac/#qa/qa1454/_index.html
- (BOOL)control:(NSControl*)control textView:(NSTextView*)textView doCommandBySelector:(SEL)commandSelector
{
    BOOL result = NO;
	
    if (commandSelector == @selector(insertNewline:))
    {
        // new line action:
        // always insert a line-break character and don’t cause the receiver to end editing
        [textView insertNewlineIgnoringFieldEditor:self];
        result = YES;
    }
    else if (commandSelector == @selector(insertTab:))
    {
        // tab action:
        // always insert a tab character and don’t cause the receiver to end editing
        [textView insertTabIgnoringFieldEditor:self];
        result = YES;
    }
	
    return result;
}

// This is called every time we type in postTextView
- (void)textDidChange:(NSNotification *)aNotification
{
	//NSLog(@"controlTextDidChange");
	// Set character count to character count label
	[postTextView setFont:[NSFont fontWithName:@"Helvetica Neue" size:13]];
	NSString *string = [postTextView string];
	NSInteger count = 256-[string length];
	// Beep if we went over count
	if (count<0) {
		NSBeep();
        [postButton setEnabled:NO];
	}
    else {
        [postButton setEnabled:YES];
    }
	[charactersLeftLabel setIntegerValue:count];
}

- (IBAction)post:(id)sender
{
	if (replyPost==nil) {
		ANDraft *newDraft = [ANDraft new];
		[newDraft setText:[postTextView string]];
		[newDraft createPostViaSession:ANSession.defaultSession completion:^(ANResponse * response, ANPost * post, NSError * error) {
			if(!post) {
				NSLog(@"There was an error posting.");
				//[self doSomethingWithError:error];
			}
			else {
				NSLog(@"Post succeeded!");
				[charactersLeftLabel setIntegerValue:256];
				[postTextView setString:@""];
				[self close];
			}
		}];
	}
	else {
		// And post it.
		[replyPost setText:[postTextView string]];
		[replyPost createPostViaSession:ANSession.defaultSession completion:^(ANResponse * response, ANPost * post, NSError * error) {
			if(!post) {
				NSLog(@"There was an error posting the reply.");
				//[self doSomethingWithError:error];
			}
			else {
				// reset the reply post and close upon success
				NSLog(@"Reply succeeded!");
				[charactersLeftLabel setIntegerValue:256];
				replyPost = nil;
				[self close];
			}
		}];
	}
}

- (void)draftReply:(ANPost*)post
{
	replyPost = [post draftReplyToAllExceptUser:[[PSCMemoryCache sharedMemory] currentUser]];
	[postTextView setString:[replyPost text]];
	// adjust character count
	[self textDidChange:nil];
}

- (void)processDraggedFile:(NSString *)fileName data:(NSData *)data
{
	[uploader uploadData:data withFileName:fileName completion:^(NSError *error, NSString *uploadString) {
		NSLog(@"Hi there!");
		[postTextView insertText:uploadString];
	}];
}

@end
