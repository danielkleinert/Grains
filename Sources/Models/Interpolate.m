//
//  Interpolate.m
//  Grains
//
//  Created by Daniel Kleinert on 28.07.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Interpolate.h"


@implementation Interpolate

@dynamic from;
@dynamic to;
@dynamic duration;


-(void)calculate{
	float percentPassed = ((UInt64)([NSDate timeIntervalSinceReferenceDate] * 1000) % (UInt64)self.duration) / self.duration;
	self.output = [NSNumber numberWithFloat: (percentPassed * (self.to - self.from)) + self.from];
}



@end
