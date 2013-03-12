//
//  PSCTableView.m
//  Sunlight
//
//  Created by Chloe Stars on 3/12/13.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "PSCTableView.h"

@implementation PSCTableView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (BOOL)validateProposedFirstResponder:(NSResponder *)responder forEvent:(NSEvent *)event
{
    // This allows the user to click on controls within a cell withough first having to select the cell row
    return YES;
	//return NO;
}

/*- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}*/

@end
