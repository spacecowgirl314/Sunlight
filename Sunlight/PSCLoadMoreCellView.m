//
//  PSCLoadMoreCellView.m
//  Sunlight
//
//  Created by Chloe Stars on 2/28/13.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "PSCLoadMoreCellView.h"

@implementation PSCLoadMoreCellView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (IBAction)loadMore:(id)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"LoadMore" object:nil];
}

/*- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}*/

@end
