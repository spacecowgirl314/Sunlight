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
	IBOutlet NSTextView *postView;
	IBOutlet NSTextField *userField;
	IBOutlet NSImageView *avatarView;
}

@property ANPost *post;
@property IBOutlet NSTextView *postView;
@property IBOutlet NSTextField *userField;
@property IBOutlet NSImageView *avatarView;
@property (retain, nonatomic) PSCNewPostController *postController;

- (IBAction)openReplyPost:(id)sender;
- (IBAction)starPost:(id)sender;
- (IBAction)repostPost:(id)sender;

@end
