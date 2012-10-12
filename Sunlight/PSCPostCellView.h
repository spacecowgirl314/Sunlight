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
	IBOutlet NSTextField *postField;
	IBOutlet NSTextField *userField;
	IBOutlet NSImageView *avatarView;
}

@property IBOutlet NSTextField *postField;
@property IBOutlet NSTextField *userField;
@property IBOutlet NSImageView *avatarView;

@end
