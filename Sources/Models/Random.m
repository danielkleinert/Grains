//
//  Random.m
//  Grains
//
//  Created by Daniel Kleinert on 05.05.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Random.h"


@implementation Random
@dynamic min;
@dynamic max;

- (NSArray*)orderdInputs{
	return [NSArray arrayWithObjects:@"min", @"max", nil];
}

-(void)calculate{
	float min = [self.min floatValue];
	float max = [self.max floatValue];
	self.output = [NSNumber numberWithFloat:(float)rand()/RAND_MAX*(max-min)+min];
}

@end
