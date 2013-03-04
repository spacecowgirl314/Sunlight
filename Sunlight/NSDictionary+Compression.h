//
//  NSDictionary+Compression.h
//  Sunlight
//
//  Created by Chloe Stars on 3/4/13.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSData+Godzippa.h"

@interface NSDictionary (Compression)

- (NSData*)compressed;
+ (NSDictionary*)decompressData:(NSData*)compressedData;

@end
