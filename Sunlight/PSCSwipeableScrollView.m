//
//  PSCSwipeableScrollView.m
//  Sunlight
//
//  Created by Chloe Stars on 1/31/13.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "PSCSwipeableScrollView.h"

@implementation PSCSwipeableScrollView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code here.
		[self setAcceptsTouchEvents:YES];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

- (BOOL)wantsScrollEventsForSwipeTrackingOnAxis:(NSEventGestureAxis)axis {
	return (axis == NSEventGestureAxisHorizontal) ? YES : NO; }

- (void)swipeWithEvent:(NSEvent *)event {
	int swipeColorValue;
	const int SwipeLeftGreen = 0;
	const int SwipeRightBlue = 1;
	const int SwipeUpRed = 2;
	const int SwipeDownYellow = 3;
	
    CGFloat x = [event deltaX];
    CGFloat y = [event deltaY];
    if (x != 0) {
        swipeColorValue = (x > 0)  ? SwipeLeftGreen : SwipeRightBlue;
    }
    if (y != 0) {
        swipeColorValue = (y > 0)  ? SwipeUpRed : SwipeDownYellow;
    }
    NSString *direction;
    switch (swipeColorValue) {
        case SwipeLeftGreen:
            direction = @"left";
            break;
        case SwipeRightBlue:
            direction = @"right";
            break;
        case SwipeUpRed:
            direction = @"up";
            break;
        case SwipeDownYellow:
        default:
            direction = @"down";
            break;
    }
	NSLog(@"Swipe %@", direction);
    /*[postCreationField setStringValue:[NSString stringWithFormat:@"Swipe %@", direction]];*/
    [self setNeedsDisplay:YES];
}

@end
