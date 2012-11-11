//
//  PSCRoundedImageView.m
//  Sunlight
//
//  Created by Chloe Stars on 10/22/12.
//  Copyright (c) 2012 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "PSCRoundedImageView.h"

@implementation PSCRoundedImageView

- (void)drawRect:(NSRect)dirtyRect
{
	NSRect fixedRect;
	
	fixedRect.origin.x = dirtyRect.origin.x;
	fixedRect.origin.y = dirtyRect.origin.y;
	fixedRect.size.width = 52;
	fixedRect.size.height = 52;
	
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(fixedRect, 2, 2) xRadius:5 yRadius:5];
	
    [path setLineWidth:2.0];
    [path addClip];
	
    [self.image drawAtPoint:NSZeroPoint
				   fromRect:fixedRect
				  operation:NSCompositeSourceOver
				   fraction: 2.0];
	
    [super drawRect:fixedRect];
	
    NSColor *strokeColor;
    /*if(self.isSelected)
    {
        strokeColor = [NSColor colorFromHexRGB:@"f9eca2"];
    }
    else
        strokeColor = [NSColor colorFromHexRGB:@"000000"];*/
	strokeColor = [NSColor blackColor];
	
    [strokeColor set];
    [NSBezierPath setDefaultLineWidth:2.0];
    [[NSBezierPath bezierPathWithRoundedRect:NSInsetRect(fixedRect, 2, 2) xRadius:5 yRadius:5] stroke];
}

@end
