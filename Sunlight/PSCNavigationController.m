//
//  PSCNavigationController.m
//  Sunlight
//
//  Created by Chloe Stars on 2/27/13.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "PSCNavigationController.h"

@implementation PSCNavigationController

- (id)init
{
	if (self==[super init])
	{
		streams = [NSMutableArray new];
	}
	return self;
}

- (void)pushStream:(id)stream
{
	[streams addObject:stream];
}

- (void)popStream:(id)stream
{
	// iterate backwards until we reach the item being removed
	for (NSUInteger i=streams.count-1; i>[streams indexOfObject:stream]; i--)
	{
		[streams removeObjectAtIndex:i];
	}
}

- (void)popStreamAtIndex:(int)index
{
	// iterate backwards until we reach the item being removed
	for (NSUInteger i=streams.count-1; i>index; i--)
	{
		[streams removeObjectAtIndex:i];
	}
}

- (PSCStream*)streamAtIndex:(int)index
{
	return [streams objectAtIndex:index];
}

- (void)clear
{
	[streams removeAllObjects];
}

@end
