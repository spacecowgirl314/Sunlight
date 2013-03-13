//
//  PSCGradientView.m
//  Sunlight
//
//  Created by Chloe Stars on 2/4/13.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "PSCGradientView.h"

@implementation PSCGradientView

// Automatically create accessor methods
@synthesize startingColor;
@synthesize endingColor;
@synthesize angle;

- (id)initWithFrame:(NSRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		// Initialization code here.
		//[self setStartingColor:[NSColor whiteColor]];
		//[self setEndingColor:[NSColor blackColor]];
		[self setStartingColor:[NSColor colorWithDeviceRed:0.965 green:0.965 blue:0.965 alpha:1.0]];
		[self setEndingColor:[NSColor colorWithDeviceRed:0.894 green:0.894 blue:0.894 alpha:1.0]];
		[self setAngle:270];
	}
	return self;
}

// from http://stackoverflow.com/a/4564630/1000339
-(void)mouseDown:(NSEvent *)theEvent {
    NSRect  windowFrame = [[self window] frame];
	
    initialLocation = [NSEvent mouseLocation];
	
    initialLocation.x -= windowFrame.origin.x;
    initialLocation.y -= windowFrame.origin.y;
}

- (void)mouseDragged:(NSEvent *)theEvent {
    NSPoint currentLocation;
    NSPoint newOrigin;
	
    NSRect  screenFrame = [[NSScreen mainScreen] frame];
    NSRect  windowFrame = [self frame];
	
    currentLocation = [NSEvent mouseLocation];
    newOrigin.x = currentLocation.x - initialLocation.x;
    newOrigin.y = currentLocation.y - initialLocation.y;
	
    // Don't let window get dragged up under the menu bar
    if( (newOrigin.y+windowFrame.size.height) > (screenFrame.origin.y+screenFrame.size.height) ){
        newOrigin.y=screenFrame.origin.y + (screenFrame.size.height-windowFrame.size.height);
    }
	
    //go ahead and move the window to the new location
    [[self window] setFrameOrigin:newOrigin];
}

- (void)drawRect:(NSRect)rect {
	if (endingColor == nil || [startingColor isEqual:endingColor]) {
		// Fill view with a standard background color
		[startingColor set];
		NSRectFill(rect);
	}
	else {
		// Fill view with a top-down gradient
		// from startingColor to endingColor
		NSGradient* aGradient = [[NSGradient alloc]
								 initWithStartingColor:startingColor
								 endingColor:endingColor];
		[aGradient drawInRect:[self bounds] angle:angle];
	}
}

@end
