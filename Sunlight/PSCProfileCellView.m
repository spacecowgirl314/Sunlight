//
//  PSCProfileCellView.m
//  Sunlight
//
//  Created by Chloe Stars on 2/21/13.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "PSCProfileCellView.h"

@implementation PSCProfileCellView
@synthesize bannerView;
@synthesize avatarView;
@synthesize userField;
@synthesize biographyView;
@synthesize bannerShadow;
@synthesize followerCount;
@synthesize followingCount;
@synthesize starredCount;
@synthesize bottomShadow;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)awakeFromNib {
	[[self bannerShadow] setStartingColor:[NSColor clearColor]];
	[[self bannerShadow] setEndingColor:[NSColor colorWithDeviceWhite:0.0f alpha:0.75f]];
    [[self bannerShadow] setAngle:270];
	[[self bottomShadow] setStartingColor:[NSColor colorWithDeviceWhite:0.0f alpha:0.20f]];
	[[self bottomShadow] setEndingColor:[NSColor clearColor]];
    [[self bottomShadow] setAngle:270];
}

/*- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}*/

@end
