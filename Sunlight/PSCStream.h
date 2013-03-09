//
//  PSCStream.h
//  Sunlight
//
//  Created by Chloe Stars on 2/27/13.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSCStream : NSObject

@property NSArray *posts;
@property NSPoint position;
@property (strong) void(^reloadPosts)(void);

@end
