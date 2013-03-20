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
@synthesize twoFingersTouches;

#define kSwipeMinimumLength 0.25

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

#pragma mark - Swiping

- (void)goBack:(id)sender
{
	
}

- (void)goForward:(id)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PopTopBreadcrumbItem" object:nil];
}

- (void)swipeWithEvent:(NSEvent *)event {
    NSLog(@"Swipe With Event");
    CGFloat x = [event deltaX];
    //CGFloat y = [event deltaY];
	
    if (x != 0) {
        (x > 0) ? [self goBack:self] : [self goForward:self];
    }
}

- (void)beginGestureWithEvent:(NSEvent *)event
{
	NSLog(@"Gesture detected!");
    /*if (![self recognizeTwoFingerGestures])
	 return;*/
	
    NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseAny inView:nil];
	
    self.twoFingersTouches = [[NSMutableDictionary alloc] init];
	
    for (NSTouch *touch in touches) {
        [twoFingersTouches setObject:touch forKey:touch.identity];
    }
}

- (void)endGestureWithEvent:(NSEvent *)event
{
	NSLog(@"Gesture end detected!");
    if (!twoFingersTouches) return;
	
    NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseAny inView:nil];
	
    // release twoFingersTouches early
    NSMutableDictionary *beginTouches = [twoFingersTouches copy];
    self.twoFingersTouches = nil;
	
    NSMutableArray *magnitudes = [[NSMutableArray alloc] init];
	
    for (NSTouch *touch in touches)
    {
        NSTouch *beginTouch = [beginTouches objectForKey:touch.identity];
		
        if (!beginTouch) continue;
		
        float magnitude = touch.normalizedPosition.x - beginTouch.normalizedPosition.x;
        [magnitudes addObject:[NSNumber numberWithFloat:magnitude]];
    }
	
    // Need at least two points
    if ([magnitudes count] < 2) return;
	
    float sum = 0;
	
    for (NSNumber *magnitude in magnitudes)
        sum += [magnitude floatValue];
	
    // Handle natural direction in Lion
    BOOL naturalDirectionEnabled = [[[NSUserDefaults standardUserDefaults] valueForKey:@"com.apple.swipescrolldirection"] boolValue];
	
    if (naturalDirectionEnabled)
        sum *= -1;
	
    // See if absolute sum is long enough to be considered a complete gesture
    float absoluteSum = fabsf(sum);
	
    if (absoluteSum < kSwipeMinimumLength) return;
	
    // Handle the actual swipe
    if (sum > 0)
    {
        [self goForward:self];
		NSLog(@"Go forward");
    } else
    {
		NSLog(@"Go back");
        [self goBack:self];
    }
	
	
}

@end
