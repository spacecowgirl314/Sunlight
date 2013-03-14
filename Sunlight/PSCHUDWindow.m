//
//  PSCHUDWindow.m
//  Sunlight
//
//  Created by Chloe Stars on 9/28/12.
//  Copyright (c) 2012 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "PSCHUDWindow.h"

@implementation PSCHUDWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
	self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	if (self!=nil) {
		[self setOpaque:NO];
		[self setBackgroundColor:[NSColor clearColor]];
	}
	
	return self;
}

@end
