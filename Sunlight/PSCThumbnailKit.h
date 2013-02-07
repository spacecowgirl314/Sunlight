//
//  PSCThumbnailKit.h
//  Sunlight
//
//  Created by Chloe Stars on 2/6/13.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    PSCMediaTypeYoutube,
    PSCMediaTypeInstagram,
    PSCMediaTypeADN
} PSCMediaType;

@interface PSCThumbnailKit : NSObject
{
	PSCMediaType mediaType;
}

@end
