//
//  PSCLoadMoreCellView.m
//  Sunlight
//
//  Created by Chloe Stars on 2/28/13.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "PSCLoadMoreCellView.h"

#define kSwipeMinimumLength 0.25

@implementation PSCLoadMoreCellView
@synthesize twoFingersTouches;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (IBAction)loadMore:(id)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"LoadMore" object:nil];
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
