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

@interface PSCNewPostController: NSWindowController {
	IBOutlet NSTextField *postTextField;
	IBOutlet NSTextField *charactersLeftLabel;
	IBOutlet NSButton *postButton;
	ANDraft *replyPost;
}

@property IBOutlet NSTextField *postTextField;
@property IBOutlet NSTextField *charactersLeftLabel;
@property IBOutlet NSButton *postButton;

- (void)draftReply:(ANPost*)post;

@end
