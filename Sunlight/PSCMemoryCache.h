//
//  PSCMemoryCache.h
//  Sunlight
//
//  Created by Chloe Stars on 2/6/13.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppNetKit.h"

@interface PSCMemoryCache : NSObject {
	NSMutableDictionary *avatarImages;
	NSMutableDictionary *streamsDictionary;
}

@property NSMutableDictionary *avatarImages;
@property NSMutableDictionary *streamsDictionary;
@property (nonatomic) NSString *authToken;
@property ANUser *currentUser;

+ (instancetype)sharedMemory;
- (NSImage*)maskImage:(NSImage *)image withMask:(NSImage *)maskImage;
- (NSDictionary*)filterNewPostsForKey:(NSString*)key posts:(NSArray*)posts;

@end
