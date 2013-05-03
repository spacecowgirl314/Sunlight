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
#import "Droplr/DroplrKit/Model/DKDropCreation.h"

typedef enum {
	PSCUploadServiceADN,
	PSCUploadServiceCloud,
	PSCUploadServiceDroplr
} PSCUploadService;

typedef void (^PSCUploadCompletion)(NSError * error, NSString *uploadString);

@interface PSCUploader : NSObject <CLAPIEngineDelegate>
{
	PSCUploadCompletion completion;
}

- (PSCUploadService)currentService;
- (BOOL)isCurrentServiceLoggedIn;
- (void)uploadData:(NSData*)data withFileName:(NSString*)fileName completion:(PSCUploadCompletion)completion;

@end
