//
//  PSCProfileCellView.m
//  Sunlight
//
//  Created by Chloe Stars on 2/21/13.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "PSCProfileCellView.h"
#import "NSButton+TextColor.h"

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
@synthesize topShadow;
@synthesize isFollowingYouField;
@synthesize followButton;
@synthesize isYou;
@synthesize user;
@synthesize bioView;

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		
	}
	return self;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)awakeFromNib
{
	[bannerShadow setStartingColor:[NSColor clearColor] endingColor:[NSColor colorWithDeviceWhite:0.0f alpha:0.75f]];
    [bannerShadow setAngle:270];
	[bottomShadow setStartingColor:[NSColor colorWithDeviceWhite:0.0f alpha:0.20f] endingColor:[NSColor clearColor]];
    [bottomShadow setAngle:270];
	[topShadow setStartingColor:[NSColor clearColor] endingColor:[NSColor colorWithDeviceWhite:0.0f alpha:0.20f]];
    [topShadow setAngle:270];
	[followButton setTextColor:[self defaultButtonColor]];
    [isYou setHidden:YES];
	[bioView setColor:[NSColor colorWithDeviceRed:0.965 green:0.965 blue:0.965 alpha:1.0]];
	[self becomeFirstResponder];
}

- (NSColor*)defaultButtonColor
{
	return [NSColor colorWithDeviceRed:0.643 green:0.643 blue:0.643 alpha:1.0];
}

- (IBAction)toggleFollow:(id)sender
{
	if (![user youFollow]) {
		[user followWithCompletion:^(ANResponse *response, ANUser *user, NSError *error) {
			if (!error) {
				[followButton setImage:[NSImage imageNamed:@"profile-following-check"]];
				[followButton setTitle:@" Following"];
				[followButton setTextColor:[NSColor colorWithDeviceRed:0.886 green:0.522 blue:0.051 alpha:1.0]];
			}
		}];
	}
	else {
		[user unfollowWithCompletion:^(ANResponse *response, ANUser *user, NSError *error) {
			[followButton setImage:[NSImage imageNamed:@"profile-following-add"]];
			[followButton setTitle:@" Follow"];
			[followButton setTextColor:[self defaultButtonColor]];
		}];
	}
}

/*- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}*/

@end
