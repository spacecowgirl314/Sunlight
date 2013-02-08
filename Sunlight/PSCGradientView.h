//
//  PSCGradientView.h
//  Sunlight
//
//  Created by Chloe Stars on 2/4/13.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface PSCGradientView : NSView
{
	NSColor *startingColor;
	NSColor *endingColor;
	int angle;
	NSPoint initialLocation;
}

// Define the variables as properties
@property(nonatomic, retain) NSColor *startingColor;
@property(nonatomic, retain) NSColor *endingColor;
@property(assign) int angle;

@end
