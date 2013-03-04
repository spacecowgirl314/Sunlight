//
//  PSCNavigationController.h
//  Sunlight
//
//  Created by Chloe Stars on 2/27/13.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSCStream.h"

@interface PSCNavigationController : NSObject
{
	@public
	NSMutableArray *streams;
}

- (void)pushStream:(PSCStream*)stream;
- (void)popStream:(PSCStream*)stream;
- (void)popStreamAtIndex:(int)index;
- (PSCStream*)streamAtIndex:(int)index;
- (void)clear;

@end
