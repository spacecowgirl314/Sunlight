//
//  PSCPostCellView.h
//  Sunlight
//
//  Created by Chloe Stars on 10/10/12.
//  Copyright (c) 2012 Phantom Sun Creative, Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppNetKit.h"

@interface PSCPostCellView : NSTableCellView {
	ANPost *post;
	IBOutlet NSTextView *postView;
	IBOutlet NSTextField *userField;
	IBOutlet NSImageView *avatarView;
}

@property IBOutlet NSTextView *postView;
@property IBOutlet NSTextField *userField;
@property IBOutlet NSImageView *avatarView;

@end
