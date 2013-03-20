//
//  PSCTextView.h
//  Sunlight
//
//  Created by Chloe Stars on 2/5/13.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol PSCTextViewDelegate

- (void)textViewMouseDown;

@end

@interface PSCTextView : NSTextView

@property id <PSCTextViewDelegate> delegate;

@end
