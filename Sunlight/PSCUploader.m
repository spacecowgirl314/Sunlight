//
//  PSCUploader.m
//  Sunlight
//
//  Created by Chloe Stars on 4/8/13.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "PSCUploader.h"

@implementation PSCUploader

- (PSCUploadService)currentService
{
	NSNumber *readLaterServiceIndexNumber = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"uploadService"];
	switch ([readLaterServiceIndexNumber integerValue]) {
		case 1:
			return PSCUploadServiceCloud;
			break;
		case 2:
			return PSCUploadServiceDroplr;
			break;
	}
	return PSCUploadServiceADN;
}

- (void)uploadData:(NSData*)data withFileName:(NSString*)fileName
{
	switch ([self currentService]) {
		case PSCUploadServiceADN:
			break;
		case PSCUploadServiceCloud: {
			CLAPIEngine *cloudEngine = [[CLAPIEngine alloc] initWithDelegate:self];
			[cloudEngine setEmail:@""];
			[cloudEngine setPassword:@""];
			[cloudEngine uploadFileWithName:fileName fileData:data userInfo:nil];
			break;
		}
		case PSCUploadServiceDroplr: {
			// Setup the app credentials
			DKAppCredentials* app = [DKAppCredentials credentialsWithPublicKey:@"yourPublicKey"
																 andPrivateKey:@"yourPrivateKey"];
			
			// Create the user agent identifier
			NSString* userAgent = [[NSString alloc] initWithFormat:@"Sunlight/%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
			
			// Create the service instance
			DKService* service = [[DKService alloc] initWithUserAgent:userAgent andAppCredentials:app];
			
			// Setting up a user
			DKUserCredentials* user = [DKUserCredentials credentialsWithEmail:@"user@email.com"
															andHashedPassword:@"SHA1HashedPassword"];
			
			// This ensures that all operations will use these credentials
			// You can also specify credentials on a per-request basis
			service.userCredentials = user;
			
			[service uploadData:data withType:nil andFilename:fileName];
			break;
		}
	}
}

@end
