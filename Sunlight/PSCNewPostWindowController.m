//
//  PSCNewPostWindowController.m
//  Sunlight
//
//  Created by Chloe Stars on 10/12/12.
//  Copyright (c) 2012 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "PSCNewPostWindowController.h"
#import "AppNetKit.h"

@interface PSCNewPostWindowController ()

@end

@implementation PSCNewPostWindowController
@synthesize postTextField;

-(id)init
{
	if (![super initWithWindowNibName:@"PSCNewPostWindowController"]) {
		return nil;
	}
	INAppStoreWindow *awindow = (INAppStoreWindow *)[self window];
	awindow.trafficLightButtonsLeftMargin = 7.0;
    awindow.fullScreenButtonRightMargin = 7.0;
    awindow.hideTitleBarInFullScreen = YES;
    awindow.centerFullScreenButton = YES;
    awindow.titleBarHeight = 40.0;
	
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
}

- (IBAction)post:(id)sender {
	ANDraft *newDraft = [ANDraft new];
	NSLog(@"post text:%@", [postTextField stringValue]);
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
