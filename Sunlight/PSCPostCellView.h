//
//  PSCPostCellView.h
//  Sunlight
//
//  Created by Chloe Stars on 10/10/12.
//  Copyright (c) 2012 Phantom Sun Creative, Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppNetKit.h"
#import "PSCNewPostController.h"

@interface PSCPostCellView : NSTableCellView {
	ANPost *post;
	IBOutlet NSScrollView *postScrollView;
	IBOutlet NSTextView *postView;
	IBOutlet NSTextField *userField;
	IBOutlet NSTextField *postCreationField;
	IBOutlet NSImageView *avatarView;
	IBOutlet NSButton *replyButton;
	IBOutlet NSButton *starButton;
	IBOutlet NSButton *repostButton;
	NSTrackingArea *trackingArea;
	NSTimer *fadeTimer;
}

@property ANPost *post;
@property IBOutlet NSScrollView *postScrollView;
@property IBOutlet NSTextView *postView;
@property IBOutlet NSTextField *userField;
@property IBOutlet NSTextField *postCreationField;
@property IBOutlet NSImageView *avatarView;
@property IBOutlet NSButton *replyButton;
@property IBOutlet NSButton *muteButton;
@property IBOutlet NSButton *repostButton;
@property IBOutlet NSButton *starButton;
@property (retain, nonatomic) PSCNewPostController *postController;

- (IBAction)openReplyPost:(id)sender;
- (IBAction)starPost:(id)sender;
- (IBAction)repostPost:(id)sender;

@end
