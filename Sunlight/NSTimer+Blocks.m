//
//  NSTimer+Blocks.m
//  Sunlight
//
//  Created by Chloe Stars on 10/14/12.
//  Copyright (c) 2012 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "NSTimer+Blocks.h"

@implementation NSTimer (Blocks)

+ (void)executeBlock__:(NSTimer*)timer
{
	if (![timer isValid]) {
		return;
		// do nothing
	}
	
	TIMER_BLOCK__ block = [timer userInfo];
	block(timer);
}

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds
									  block:(TIMER_BLOCK__)block repeats:(BOOL)repeats
{
	NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:seconds
													  target:self
													selector:@selector(executeBlock__:)
													userInfo:[block copy]
													 repeats:repeats];
	return timer;
	
}

@end
