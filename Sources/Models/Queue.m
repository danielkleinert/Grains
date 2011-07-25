//
//  Queue.m
//  Grains
//
//  Created by Daniel Kleinert on 04.07.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Queue.h"


@implementation Queue
@dynamic values;
@dynamic index;

- (NSArray*)orderdInputs{
	return [[NSArray alloc] init];
}

-(void)calculate{
	if ([self.values count] >0 ) {
		UInt index = [self.index unsignedIntValue];
		self.output = [self.values objectAtIndex:index % [self.values count]];
		self.index = [NSNumber numberWithFloat:index+1 ];
	}
}

@end
