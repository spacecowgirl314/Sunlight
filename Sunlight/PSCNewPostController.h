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
#import "PSCAttachmentTextView.h"
#import "PSCUploader.h"

@interface PSCNewPostController: NSWindowController <NSTextDelegate, PSCAttachmentTextViewDelegate> {
	IBOutlet NSTextField *postTextField;
	IBOutlet PSCAttachmentTextView *postTextView;
	IBOutlet NSTextField *charactersLeftLabel;
	IBOutlet NSButton *postButton;
	IBOutlet NSButton *cancelButton;
	IBOutlet PSCGradientView *bottomGradientView;
	IBOutlet PSCGradientView *topGradientView;
	IBOutlet NSImageView *avatarView;
	PSCUploader *uploader;
	ANDraft *replyPost;
}

@property IBOutlet NSTextField *postTextField;
@property IBOutlet PSCAttachmentTextView *postTextView;
@property IBOutlet NSTextField *charactersLeftLabel;
@property IBOutlet NSButton *postButton;
@property IBOutlet NSButton *cancelButton;
@property IBOutlet PSCGradientView *bottomGradientView;
@property IBOutlet PSCGradientView *topGradientView;
@property IBOutlet NSImageView *avatarView;
@property (assign) IBOutlet NSView *titleView;

- (void)draftReply:(ANPost*)post;
- (IBAction)pressCancel:(id)sender;

@end
