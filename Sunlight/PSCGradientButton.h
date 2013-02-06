//
//  PSCGradientButton.h
//  Sunlight
//
//  Created by Chloe Stars on 2/6/13.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PSCGradientButton : NSButton
{
	NSColor *startingColor;
	NSColor *endingColor;
	int angle;
}

// Define the variables as properties
@property(nonatomic, retain) NSColor *startingColor;
@property(nonatomic, retain) NSColor *endingColor;
@property(assign) int angle;

@end
