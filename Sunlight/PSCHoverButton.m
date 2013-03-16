//
//  PSCHoverButton.m
//  Sunlight
//
//  Created by Chloe Stars on 3/15/13.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "PSCHoverButton.h"

@implementation PSCHoverButton

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
		int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveInActiveApp);
		NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
													 options:opts
													   owner:self
													userInfo:nil];
		[self addTrackingArea:trackingArea];
	}
	
	return self;
}

- (void)mouseEntered:(NSEvent *)theEvent
{
	self.image = self.alternateImage;
}

- (void)mouseExited:(NSEvent *)theEvent
{
	self.image = nil;
}

- (void)clear
{
	self.image = nil;
}

@end
