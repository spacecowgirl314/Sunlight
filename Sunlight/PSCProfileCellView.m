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
@synthesize isFollowingYouField;
@synthesize followButton;
@synthesize user;

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

- (void)awakeFromNib {
	[bannerShadow setStartingColor:[NSColor clearColor]];
	[bannerShadow setEndingColor:[NSColor colorWithDeviceWhite:0.0f alpha:0.75f]];
    [bannerShadow setAngle:270];
	[bottomShadow setStartingColor:[NSColor colorWithDeviceWhite:0.0f alpha:0.20f]];
	[bottomShadow setEndingColor:[NSColor clearColor]];
    [bottomShadow setAngle:270];
	[followButton setTextColor:[self defaultButtonColor]];
	[self becomeFirstResponder];
}

- (NSColor*)defaultButtonColor {
	return [NSColor colorWithDeviceRed:0.643 green:0.643 blue:0.643 alpha:1.0];
}

- (IBAction)toggleFollow:(id)sender {
	if (![user youFollow]) {
		[user followWithCompletion:^(ANResponse *response, ANUser *user, NSError *error) {
			if (!error) {
				[followButton setImage:[NSImage imageNamed:@"profile-following-check"]];
				[followButton setTitle:@"Following"];
				[followButton setTextColor:[NSColor colorWithDeviceRed:0.161 green:0.376 blue:0.733 alpha:1]];
			}
		}];
	}
	else {
		[user unfollowWithCompletion:^(ANResponse *response, ANUser *user, NSError *error) {
			[followButton setImage:[NSImage imageNamed:@"profile-following-add"]];
			[followButton setTitle:@"Follow"];
			[followButton setTextColor:[self defaultButtonColor]];
		}];
	}
}

/*- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}*/

@end
