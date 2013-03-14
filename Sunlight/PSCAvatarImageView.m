//
//  PSCAvatarImageView.m
//  Sunlight
//
//  Created by Chloe Stars on 2/22/13.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "PSCAvatarImageView.h"

@implementation PSCAvatarImageView

- (void)awakeFromNib
{
	/*[self setAcceptsTouchEvents:YES];
	[self becomeFirstResponder];*/
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

/*- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent 
{
    return YES;
}*/

- (void)setTarget:(id)target
{
    realTarget = target;
    super.target = self;
}

- (void)setAction:(SEL)action
{
    realAction = action;
    super.action = @selector(pressed);
}

- (void)mouseUp:(NSEvent *)theEvent
{
	[realTarget performSelector:realAction withObject:nil afterDelay:0];
}

/*- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}*/

@end
