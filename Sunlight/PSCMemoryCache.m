//
//  PSCMemoryCache.m
//  Sunlight
//
//  Created by Chloe Stars on 2/6/13.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "PSCMemoryCache.h"

@implementation PSCMemoryCache
@synthesize avatarImages;
@synthesize streamsDictionary;
@synthesize authToken = _authToken;

- (id)init {
	if (self==[super init])
	{
		avatarImages = [NSMutableDictionary new];
		streamsDictionary = [NSMutableDictionary new];
	}
	return self;
}

+ (instancetype)sharedMemory
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (CGImageRef)nsImageToCGImageRef:(NSImage*)image;
{
    NSData * imageData = [image TIFFRepresentation];
    CGImageRef imageRef;
    if(!imageData) return nil;
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
    imageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
    return imageRef;
}

- (NSImage*)imageFromCGImageRef:(CGImageRef)image
{
    NSRect imageRect = NSMakeRect(0.0, 0.0, 0.0, 0.0);
    CGContextRef imageContext = nil;
    NSImage* newImage = nil; // Get the image dimensions.
    imageRect.size.height = CGImageGetHeight(image);
    imageRect.size.width = CGImageGetWidth(image);
	
    // Create a new image to receive the Quartz image data.
    newImage = [[NSImage alloc] initWithSize:imageRect.size];
    [newImage lockFocus];
	
    // Get the Quartz context and draw.
    imageContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    CGContextDrawImage(imageContext, *(CGRect*)&imageRect, image); [newImage unlockFocus];
    return newImage;
}

- (NSImage*)maskImage:(NSImage *)image withMask:(NSImage *)maskImage {
	
	CGImageRef maskRef = [self nsImageToCGImageRef:maskImage];
	
	CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
										CGImageGetHeight(maskRef),
										CGImageGetBitsPerComponent(maskRef),
										CGImageGetBitsPerPixel(maskRef),
										CGImageGetBytesPerRow(maskRef),
										CGImageGetDataProvider(maskRef), NULL, false);
	
	CGImageRef masked = CGImageCreateWithMask([self nsImageToCGImageRef:image], mask);
	return [self imageFromCGImageRef:masked];
	
}

- (void)setAuthToken:(NSString *)apiKey {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	_authToken = apiKey;
	if (apiKey) {
		[defaults setObject:apiKey forKey:@"access_token"];
	} else {
		[defaults removeObjectForKey:@"access_token"];
	}
	[defaults synchronize];
}

- (NSString*)authToken {
	if (!_authToken) {
		_authToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"access_token"];
		//NSLog(@"Read API Key %@", _authToken);
	}
	return _authToken;
}

/*
 this could should take the new posts response and filter out posts we already have with the exception of deleted posts
 */
- (void)filterNewPostsForKey:(NSString*)key posts:(NSArray*)post {
	NSArray *currentArray = [streamsDictionary objectForKey:key];
	/* example deduplication code
	NSMutableArray* filterResults = [[NSMutableArray alloc] init];
	BOOL copy;
	
	if (![category count] == 0) {
		for (CategoryArray *a1 in category) {
			copy = YES;
			for (CategoryArray *a2 in filterResults) {
				if ([a1.label isEqualToString:a2.label] && [a1.url isEqualToString:a2.url]) {
					copy = NO;
					break;
				}
			}
			if (copy) {
				[filterResults addObject:a1];
			}
		}
	}
	*/
}

@end
