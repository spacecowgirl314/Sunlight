//
//  PSCProfileCellView.h
//  Sunlight
//
//  Created by Chloe Stars on 2/21/13.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PSCGradientView.h"

@interface PSCProfileCellView : NSTableCellView

@property IBOutlet NSImageView *bannerView;
@property IBOutlet NSImageView *avatarView;
@property IBOutlet NSTextField *userField;
@property IBOutlet NSTextField *biographyView;
@property IBOutlet PSCGradientView *bannerShadow;
@property IBOutlet NSTextField *followerCount;
@property IBOutlet NSTextField *followingCount;
@property IBOutlet NSTextField *starredCount;
@property IBOutlet PSCGradientView *bottomShadow;
@property IBOutlet NSTextField *isFollowingYouField;
@property IBOutlet NSButton *followButton;


@end
