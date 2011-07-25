//
//  ExpandView.m
//  
//
//  Created by Daniel Kleinert on 06.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ExpandView.h"


@implementation ExpandView


- (void) awakeFromNib
{
    [super awakeFromNib];
    height = [self frame].size.height;
}

- (void)setFrame:(NSRect)frameRect
{
	if(0 < [[self subviews] count])
	{
		// prevent sizing smaller than last subview
		//NSView    *subview = [[self subviews] lastObject];
		//NSRect    subviewFrame = [subview frame];
		NSRect    superviewFrame = [[self superview] frame];
		
		frameRect.size.width = superviewFrame.size.width;
		frameRect.size.height = MAX(height, superviewFrame.size.height);
	}
	[super setFrame:frameRect];
}

@end
