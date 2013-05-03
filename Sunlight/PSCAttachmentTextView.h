//
//  PSCAttachmentTextView.h
//  Sunlight
//
//  Created by Chloe Stars on 4/8/13.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol PSCAttachmentTextViewDelegate <NSObject>

- (void)processDraggedFile:(NSString*)fileName data:(NSData*)data;

@end

@interface PSCAttachmentTextView : NSTextView

@property id <PSCAttachmentTextViewDelegate> delegate;

@end
