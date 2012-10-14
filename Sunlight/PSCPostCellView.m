//
//  PSCPostCellView.m
//  Sunlight
//
//  Created by Chloe Stars on 10/10/12.
//  Copyright (c) 2012 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "PSCPostCellView.h"

@implementation PSCPostCellView
@synthesize post;
@synthesize postView;
@synthesize userField;
@synthesize avatarView;

- (IBAction)openReplyPost:(id)sender {
	if (!self.postController) {
		PSCNewPostController *pC = [[PSCNewPostController alloc] init];
		self.postController =  pC;
	}
	
	[self.postController draftReply:post];
	[self.postController showWindow:self];
	//[self.postController processResults:[questionField stringValue]];
}

- (IBAction)starPost:(id)sender {
	[post starWithCompletion:^(ANResponse *response, ANPost *starredPost, NSError *error) {
		if (!starredPost) {
			NSLog(@"There was an error starring the post.");
		}
		else {
			NSLog(@"Starring was successful.");
		}
	}];
}

- (IBAction)repostPost:(id)sender {
	[post repostWithCompletion:^(ANResponse *response, ANPost *repostPost, NSError *error) {
		if (!repostPost) {
			NSLog(@"There was an error reposting the post.");
		}
		else {
			NSLog(@"Reposting was successful.");
		}
	}];
}

- (IBAction)deletePost:(id)sender {
	[post deleteWithCompletion:^(ANResponse *response, ANPost *deletedPost, NSError *error) {
		if (!deletedPost) {
			NSLog(@"There was an error deleting the post.");
		}
		else {
			NSLog(@"Post was deleted successfully.");
		}
	}];
}

@end
