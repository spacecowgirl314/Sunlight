//
//  PSCGradientButton.m
//  Sunlight
//
//  Created by Chloe Stars on 2/6/13.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "PSCGradientButton.h"

@implementation PSCGradientButton

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
		[self setStartingColor:[NSColor colorWithDeviceRed:0.965 green:0.965 blue:0.965 alpha:1.0]];
		[self setEndingColor:[NSColor colorWithDeviceRed:0.894 green:0.894 blue:0.894 alpha:1.0]];
		[self setAngle:270];
	}
	return self;
}

- (void)drawRect:(NSRect)frame {
	/*NSGraphicsContext *context = [NSGraphicsContext currentContext];
	[context saveGraphicsState];
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
	[context restoreGraphicsState];*/
	
	NSGraphicsContext *ctx = [NSGraphicsContext currentContext];
	
	CGFloat roundedRadius = 3.0f;
	
	// Outer stroke (drawn as gradient)
	
	[ctx saveGraphicsState];
	NSBezierPath *outerClip = [NSBezierPath bezierPathWithRoundedRect:frame
															  xRadius:roundedRadius
															  yRadius:roundedRadius];
	[outerClip setClip];
	
	NSGradient *outerGradient = [[NSGradient alloc] initWithColorsAndLocations:
								 [NSColor colorWithDeviceWhite:0.20f alpha:1.0f], 0.0f,
								 [NSColor colorWithDeviceWhite:0.21f alpha:1.0f], 1.0f,
								 nil];
	
	[outerGradient drawInRect:[outerClip bounds] angle:90.0f];
	[ctx restoreGraphicsState];
	
	// Background gradient
	
	[ctx saveGraphicsState];
	NSBezierPath *backgroundPath =
    [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(frame, 2.0f, 2.0f)
                                    xRadius:roundedRadius
                                    yRadius:roundedRadius];
	[backgroundPath setClip];
	
	NSGradient *backgroundGradient = [[NSGradient alloc]
									  initWithStartingColor:endingColor
									  endingColor:startingColor];
	
	[backgroundGradient drawInRect:[backgroundPath bounds] angle:270.0f];
	[ctx restoreGraphicsState];
	
	// Dark stroke
	
	[ctx saveGraphicsState];
	[[NSColor colorWithDeviceWhite:0.12f alpha:1.0f] setStroke];
	[[NSBezierPath bezierPathWithRoundedRect:NSInsetRect(frame, 1.5f, 1.5f)
									 xRadius:roundedRadius
									 yRadius:roundedRadius] stroke];
	[ctx restoreGraphicsState];
	
	// Inner light stroke
	
	[ctx saveGraphicsState];
	[[NSColor colorWithDeviceWhite:1.0f alpha:0.05f] setStroke];
	[[NSBezierPath bezierPathWithRoundedRect:NSInsetRect(frame, 2.5f, 2.5f)
									 xRadius:roundedRadius
									 yRadius:roundedRadius] stroke];
	[ctx restoreGraphicsState];
	
	// Draw darker overlay if button is pressed
	
	/*if([self isHighlighted]) {
		[ctx saveGraphicsState];
		[[NSBezierPath bezierPathWithRoundedRect:NSInsetRect(frame, 2.0f, 2.0f)
										 xRadius:roundedRadius
										 yRadius:roundedRadius] setClip];
		[[NSColor colorWithCalibratedWhite:0.0f alpha:0.35] setFill];
		NSRectFillUsingOperation(frame, NSCompositeSourceOver);
		[ctx restoreGraphicsState];
	}*/
}


@end
