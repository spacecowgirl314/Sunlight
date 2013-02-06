//
//  PSCNewPostWindowController.h
//  Sunlight
//
//  Created by Chloe Stars on 10/12/12.
//  Copyright (c) 2012 Phantom Sun Creative, Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "INAppStoreWindow.h"
#import "AppNetKit.h"
#import "PSCGradientView.h"
#import "PSCGradientButton.h"

@interface PSCNewPostController: NSWindowController {
	IBOutlet NSTextField *postTextField;
	IBOutlet NSTextField *charactersLeftLabel;
	IBOutlet PSCGradientButton *postButton;
	IBOutlet PSCGradientButton *cancelButton;
	IBOutlet PSCGradientView *bottomGradientView;
	IBOutlet PSCGradientView *topGradientView;
	ANDraft *replyPost;
}

@property IBOutlet NSTextField *postTextField;
@property IBOutlet NSTextField *charactersLeftLabel;
@property IBOutlet PSCGradientButton *postButton;
@property IBOutlet PSCGradientButton *cancelButton;
@property IBOutlet PSCGradientView *bottomGradientView;
@property IBOutlet PSCGradientView *topGradientView;

- (void)draftReply:(ANPost*)post;

@end
