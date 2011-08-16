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
	switch (self.mode) {
		case grainMode:
			grainCounter--;
			if (grainCounter == 0) {
				[super updateForRound:round];
				grainCounter = self.grains;
			}
			break;
		case timeMode: {
			NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate] * 1000;
			if (refreshTime < now){
				[super updateForRound:round];
				int timesToAdd = ((now - refreshTime) / self.milliseconds) + 1;
				refreshTime = refreshTime + timesToAdd * self.milliseconds;
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
	refreshTime = 0;
	[self addObserver:self forKeyPath:@"mode" options:NSKeyValueObservingOptionPrior context:@"reset"];	
	[self addObserver:self forKeyPath:@"grains" options:NSKeyValueObservingOptionPrior context:@"reset"];	
	[self addObserver:self forKeyPath:@"milliseconds" options:NSKeyValueObservingOptionPrior context:@"reset"];	
}

- (void)willTurnIntoFault{
	[super  willTurnIntoFault];
	[self removeObserver:self forKeyPath:@"mode"];
	[self removeObserver:self forKeyPath:@"script"];
	[self removeObserver:self forKeyPath:@"milliseconds"];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if ([(NSString*)objc_unretainedObject(context) isEqualToString:@"reset"])	{
		[super updateForRound:0];
		switch (self.mode) {
			case grainMode:
					grainCounter = self.grains;
				break;
			case timeMode:
				refreshTime = [NSDate timeIntervalSinceReferenceDate] * 1000 + self.milliseconds;
				break;
		}
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

@end
