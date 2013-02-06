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
		//[self setStartingColor:[NSColor blueColor]];
		//[self setEndingColor:[NSColor greenColor]];
		[self setStartingColor:[NSColor colorWithDeviceRed:0.941 green:0.941 blue:0.941 alpha:1.0]];
		[self setEndingColor:[NSColor colorWithDeviceRed:0.894 green:0.894 blue:0.894 alpha:1.0]];
		[self setAngle:270];
	}
	return self;
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
