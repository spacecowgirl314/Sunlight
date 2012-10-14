//
//  PSCNewPostWindowController.m
//  Sunlight
//
//  Created by Chloe Stars on 10/12/12.
//  Copyright (c) 2012 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "PSCNewPostController.h"
#import "AppNetKit.h"

@interface PSCNewPostController ()

@end

@implementation PSCNewPostController
@synthesize postTextField, charactersLeftLabel;
@synthesize postButton;

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
    _window.titleBarHeight = 40.0;
	
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
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:NSControlTextDidChangeNotification object:postTextField];
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
		}
	}];
}

@end
