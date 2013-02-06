//
//  PSCNewPostWindowController.m
//  Sunlight
//
//  Created by Chloe Stars on 10/12/12.
//  Copyright (c) 2012 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "PSCNewPostController.h"

@interface PSCNewPostController ()

@end

@implementation PSCNewPostController
@synthesize postTextField, charactersLeftLabel;
@synthesize postButton, bottomGradientView;
@synthesize topGradientView, cancelButton;
@synthesize avatarView;

-(id)init
{
	if (![super initWithWindowNibName:@"PSCNewPost"]) {
		return nil;
	}
	
	// Setup INAppStoreWindow custom window styling
	INAppStoreWindow *_window = (INAppStoreWindow *)[self window];
	_window.trafficLightButtonsLeftMargin = 7.0;
    _window.fullScreenButtonRightMargin = 7.0;
    _window.hideTitleBarInFullScreen = YES;
    _window.centerFullScreenButton = YES;
    _window.titleBarHeight = 20.0;
	
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

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
	
	NSColor *topColor = [NSColor colorWithDeviceRed:0.208 green:0.208 blue:0.208 alpha:1.0];
	NSColor *bottomColor = [NSColor colorWithDeviceRed:0.094 green:0.094 blue:0.094 alpha:1.0];
	[bottomGradientView setStartingColor:topColor];
	[bottomGradientView setEndingColor:bottomColor];
	
	topColor = [NSColor colorWithDeviceRed:0.98 green:0.98 blue:0.98 alpha:1.0];
	bottomColor = [NSColor colorWithDeviceRed:0.831 green:0.831 blue:0.831 alpha:1.0];
	[topGradientView setStartingColor:topColor];
	[topGradientView setEndingColor:bottomColor];
	
	/*topColor = [NSColor colorWithDeviceRed:0.435 green:0.635 blue:0.878 alpha:1.0];
	bottomColor = [NSColor colorWithDeviceRed:0.141 green:0.357 blue:0.741 alpha:1.0];
	[postButton setStartingColor:topColor];
	[postButton setEndingColor:bottomColor];*/
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:NSControlTextDidChangeNotification object:postTextField];
}

- (IBAction)pressCancel:(id)sender {
	[postTextField setStringValue:@""];
	[[self window] close];
}

// This is called every time we type in postTextField
- (void)textDidChange:(NSNotification *)aNotification
{
	//NSLog(@"controlTextDidChange");
	// Set character count to character count label
	NSString *string = [postTextField stringValue];
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

- (IBAction)post:(id)sender {
	if (replyPost==nil) {
		ANDraft *newDraft = [ANDraft new];
		[newDraft setText:[postTextField stringValue]];
		[newDraft createPostViaSession:ANSession.defaultSession completion:^(ANResponse * response, ANPost * post, NSError * error) {
			if(!post) {
				NSLog(@"There was an error posting.");
				//[self doSomethingWithError:error];
			}
			else {
				NSLog(@"Post succeeded!");
				[postTextField setStringValue:@""];
				[self close];
			}
		}];
	}
	else {
		// And post it.
		[replyPost setText:[postTextField stringValue]];
		[replyPost createPostViaSession:ANSession.defaultSession completion:^(ANResponse * response, ANPost * post, NSError * error) {
			if(!post) {
				NSLog(@"There was an error posting the reply.");
				//[self doSomethingWithError:error];
			}
			else {
				// reset the reply post and close upon success
				NSLog(@"Reply succeeded!");
				replyPost = nil;
				[self close];
			}
		}];
	}
}

- (void)draftReply:(ANPost*)post {
	replyPost = [post draftReply];
	[postTextField setStringValue:[replyPost text]];
	// adjust character count
	[self textDidChange:nil];
}

@end
