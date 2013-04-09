//
//  PSCUploader.h
//  Sunlight
//
//  Created by Chloe Stars on 4/8/13.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cloud.h"
#import "DroplrKit.h"

typedef enum {
	PSCUploadServiceADN,
	PSCUploadServiceCloud,
	PSCUploadServiceDroplr
} PSCUploadService;

@interface PSCUploader : NSObject <CLAPIEngineDelegate>

@end
