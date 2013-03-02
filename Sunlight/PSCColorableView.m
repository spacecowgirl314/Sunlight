//
//  PSCColorableView.m
//  Sunlight
//
//  Created by Chloe Stars on 3/1/13.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "PSCColorableView.h"

@implementation PSCColorableView
@synthesize color;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		color = [NSColor whiteColor];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
	[color setFill];
	NSRectFill(dirtyRect);
}

@end
