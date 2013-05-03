//
//  PSCUploader.m
//  Sunlight
//
//  Created by Chloe Stars on 4/8/13.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "PSCUploader.h"
#import <MagicKit/MagicKit.h>

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

- (BOOL)isCurrentServiceLoggedIn
{
	switch ([self currentService]) {
		case PSCUploadServiceCloud: {
			CLAPIEngine *cloudEngine = [[CLAPIEngine alloc] initWithDelegate:self];
			[cloudEngine setEmail:[[NSUserDefaults standardUserDefaults] stringForKey:@"cloudEmail"]];
			[cloudEngine setPassword:[[NSUserDefaults standardUserDefaults] stringForKey:@"cloudPassword"]];
			NSLog(@"%@ info", [cloudEngine getAccountInformationWithUserInfo:nil]);
		}
		default:
			break;
	}
	return NO;
}

- (void)uploadData:(NSData*)data withFileName:(NSString*)fileName completion:(PSCUploadCompletion)_completion
{
	completion = _completion;
	switch ([self currentService]) {
		case PSCUploadServiceADN:
			break;
		case PSCUploadServiceCloud: {
			CLAPIEngine *cloudEngine = [[CLAPIEngine alloc] initWithDelegate:self];
			[cloudEngine setEmail:[[NSUserDefaults standardUserDefaults] stringForKey:@"cloudEmail"]];
			[cloudEngine setPassword:[[NSUserDefaults standardUserDefaults] stringForKey:@"cloudPassword"]];
			[cloudEngine uploadFileWithName:fileName fileData:data userInfo:@"Uploads are awesome!"];
			break;
		}
		case PSCUploadServiceDroplr: {
			// Setup the app credentials
			DKAppCredentials* app = [DKAppCredentials credentialsWithPublicKey:@"25e34b078ec3175918b41d6166ab56c8079d69a1"
																 andPrivateKey:@"fcbb1b70aadcbaff134f8d4918a9b0201a622ea6"];
			
			// Create the user agent identifier
			NSString* userAgent = [[NSString alloc] initWithFormat:@"Sunlight/%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
			
			// Create the service instance
			DKService* service = [[DKService alloc] initWithUserAgent:userAgent andAppCredentials:app];
			
			// Setting up a user
			DKUserCredentials* user = [DKUserCredentials credentialsWithEmail:[[NSUserDefaults standardUserDefaults] stringForKey:@"droplrEmail"]
															andHashedPassword:[[NSUserDefaults standardUserDefaults] stringForKey:@"droplrPassword"]];
			
			// This ensures that all operations will use these credentials
			// You can also specify credentials on a per-request basis
			service.userCredentials = user;
			
			GEMagicResult *magicResult = [GEMagicKit magicForData:data];
			
			DKOperation *operation = [service uploadData:data withType:[magicResult mimeType] andFilename:fileName];
			operation.uploadProgressBlock = ^(NSUInteger current, NSUInteger total) {
				// Like all other callbacks, this one is also
				// guaranteed to be called on the main thread
				NSLog(@"Transferred %@ of %@", DKPrettySize(current), DKPrettySize(total));
			};
			[operation execute:^(DKDropCreation* drop) {
				completion(nil, [drop shortlink]);
			} failure:^(NSError *error) {
				completion(error, nil);
			}];
			break;
		}
	}
}

#pragma mark - Service Completion Delegates

- (void)fileUploadDidSucceedWithResultingItem:(CLWebItem *)item connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo
{
	// URL, contentURL, or remoteURL
	completion(nil, [[item URL] absoluteString]);
}

#pragma mark - Service Progress Delegates

#pragma mark - Service Failure Delegates

- (void)requestDidFailWithError:(NSError *)error connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo
{
	completion(error, nil);
}

@end
