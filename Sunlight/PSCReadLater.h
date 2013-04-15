//
//  PSCReadLater.h
//  Sunlight
//
//  Created by Chloe Stars on 4/12/13.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	PSCReadLaterServiceReadingList,
	PSCReadLaterServicePocket,
	PSCReadLaterServiceInstapaper
} PSCReadLaterService;

@interface PSCReadLater : NSObject

- (PSCReadLaterService)currentService;

@end
