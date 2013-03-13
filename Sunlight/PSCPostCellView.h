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
	IBOutlet NSImageView *repostImageView;
	IBOutlet NSButton *repostedUserButton;
    IBOutlet NSButton *deleteButton;
	IBOutlet NSMenu *moreMenu;
	IBOutlet NSButton *moreButton;
	NSTrackingArea *trackingArea;
	NSTimer *fadeTimer;
	CGFloat scrollDeltaX;
	CGFloat scrollDeltaY;
}

@property ANPost *post;
@property IBOutlet NSScrollView *postScrollView;
@property IBOutlet NSTextView *postView;
@property IBOutlet NSTextField *userField;
@property IBOutlet NSTextField *postCreationField;
@property IBOutlet NSImageView *avatarView;
@property IBOutlet NSButton *conversationButton;
@property IBOutlet NSButton *replyButton;
@property IBOutlet NSButton *muteButton;
@property IBOutlet NSButton *repostButton;
@property IBOutlet NSButton *starButton;
@property IBOutlet NSImageView *repostImageView;
@property IBOutlet NSButton *repostedUserButton;
@property IBOutlet NSButton *deleteButton;
@property (retain, nonatomic) PSCNewPostController *postController;

- (IBAction)openReplyPost:(id)sender;
- (IBAction)starPost:(id)sender;
- (IBAction)repostPost:(id)sender;
- (IBAction)deletePost:(id)sender;
- (IBAction)muteUser:(id)sender;
- (IBAction)viewRepostUser:(id)sender;
- (IBAction)viewUser:(id)sender;
- (IBAction)openConversation:(id)sender;
- (IBAction)openUser:(id)sender;
- (IBAction)openMore:(id)sender;
- (IBAction)addToReadingList:(id)sender;
- (IBAction)addToPocket:(id)sender;
- (IBAction)copyContents:(id)sender;
- (IBAction)copyLink:(id)sender;
- (NSColor*)defaultButtonColor;
- (void)hideRepost;
- (void)showRepost;

@end
