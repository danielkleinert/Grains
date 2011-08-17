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
@dynamic autoReverse;


-(void)calculate{
	
	int progressInTwoDurations = (int)((UInt64)([NSDate timeIntervalSinceReferenceDate] * 1000) % (UInt64)(2 * self.duration));
	float percentPassed = progressInTwoDurations / self.duration;
	if (progressInTwoDurations > self.duration) {
		if (self.autoReverse) {
			// percentPassed = 1 - ((progressInTwoDurations - self.duration) / self.duration);
			percentPassed = 2 - percentPassed;
		} else {
			percentPassed = percentPassed -1;
		}
	} 
	self.output = [NSNumber numberWithFloat: (percentPassed * (self.to - self.from)) + self.from];
}

-(BOOL)validateDuration:(id *)ioValue error:(NSError **)outError{
	if ([*ioValue floatValue] <= 0) {
		*ioValue = [NSNumber numberWithFloat:0.0001];
	}
	return YES;
}


@end
