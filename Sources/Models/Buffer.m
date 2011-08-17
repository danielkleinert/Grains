//
//  Buffer.m
//  Grains
//
//  Created by Daniel Kleinert on 16.08.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Buffer.h"


@implementation Buffer

@dynamic mode;
@dynamic grains;
@dynamic milliseconds;
@dynamic input;

enum modes{
	grainMode = 0,
	timeMode = 1,
};

- (NSArray*)orderdInputs{
	return [NSArray arrayWithObjects:@"input", @"grains", @"milliseconds", nil];
}

-(void)updateForRound:(int)round{
	switch ([self.mode intValue]) {
		case grainMode:
			if (grainCounter == 0) {
				[super updateForRound:round];
				grainCounter = [self.grains intValue];
			}
			grainCounter--;
			break;
		case timeMode: {
			NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate] * 1000;
			if (refreshTime < now){
				[super updateForRound:round];
				int timesToAdd = ((now - refreshTime) / [self.milliseconds intValue]) + 1;
				refreshTime = refreshTime + timesToAdd * [self.milliseconds intValue];
			}
			break;
		}
	}
} 



-(void)calculate{
	self.output = self.input;
}


- (void)awake {
	[super awake];
	grainCounter = 0;
	refreshTime = [NSDate timeIntervalSinceReferenceDate] * 1000;
}


-(BOOL)validateGrains:(id *)ioValue error:(NSError **)outError{
	if ([*ioValue intValue] < 1) {
		*ioValue = [NSNumber numberWithInt:1];
	}
	return YES;
}

-(BOOL)validateMilliseconds:(id *)ioValue error:(NSError **)outError{
	if ([*ioValue intValue] < 1) {
		*ioValue = [NSNumber numberWithInt:1];
	}
	return YES;
}

@end
