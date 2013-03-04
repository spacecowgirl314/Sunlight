//
//  NSDictionary+Compression.m
//  Sunlight
//
//  Created by Chloe Stars on 3/4/13.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "NSDictionary+Compression.h"

@implementation NSDictionary (Compression)

- (NSData*)compressed {
	NSError *error;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
									options:0
									  error:&error];
	NSString *dictionaryString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
	NSData *originalData = [dictionaryString dataUsingEncoding:NSUTF8StringEncoding];
	NSData *compressedData = [originalData dataByGZipCompressingWithError:nil];
	//NSString *compressedString = [[NSString alloc] initWithData:compressedData encoding:NSUTF8StringEncoding];
	return compressedData; //[compressedString dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSDictionary*)decompressData:(NSData*)compressedData {
	NSError *error;
	NSData *jsonData = [compressedData dataByGZipDecompressingDataWithError:nil];
	return [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
}

@end
