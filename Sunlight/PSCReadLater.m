//
//  PSCReadLater.m
//  Sunlight
//
//  Created by Chloe Stars on 4/12/13.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "PSCReadLater.h"

@implementation PSCReadLater

- (PSCReadLaterService)currentService
{
	NSNumber *readLaterServiceIndexNumber = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"readLaterService"];
	switch ([readLaterServiceIndexNumber integerValue]) {
		case 1:
			return PSCReadLaterServicePocket;
			break;
		case 2:
			return PSCReadLaterServiceInstapaper;
			break;
	}
	return PSCReadLaterServiceReadingList;
}

@end
