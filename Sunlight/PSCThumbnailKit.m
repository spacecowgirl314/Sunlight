//
//  PSCThumbnailKit.m
//  Sunlight
//
//  Created by Chloe Stars on 2/6/13.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "PSCThumbnailKit.h"
#import "RegexKitLite.h"

@implementation PSCThumbnailKit

- (id)initWithMediaString:(NSString*)mediaString
{
	// our site array regexes
	NSArray *youtubeRegexArray = [mediaString componentsMatchedByRegex:@"(?<=v=)[a-zA-Z0-9-_]+(?=&)|(?<=[0-9]/)[^&\n]+|(?<=v=)[^&\n]+"];
	// run through our arrays to see if any of them have items
	if ([youtubeRegexArray count]>0) {
		mediaType = PSCMediaTypeYoutube;
	}
	//https://github.com/collective/collective.oembed/blob/master/collective/oembed/endpoints.py
	//
	
	return self;
}

@end
