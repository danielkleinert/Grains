//
//  NewObjectView.m
//  Grains
//
//  Created by Daniel Kleinert on 30.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NewObjectView.h"


@implementation NewObjectView


- (NSView *)hitTest:(NSPoint)aPoint
{
    // don't allow any mouse clicks for subviews in this view
	return ( NSPointInRect(aPoint,[self frame]) ? self : nil);
}

-(void)mouseDown:(NSEvent *)theEvent
{
	[super mouseDown:theEvent];
	if([theEvent clickCount] > 1)
		[NSApp sendAction:@selector(addNewObject:) to:nil from:self];
}

@end
