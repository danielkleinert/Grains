//
//  Math.m
//  Grains
//
//  Created by Daniel Kleinert on 14.08.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Math.h"
#import "DDMathParser/NSString+DDMathParsing.h"


@implementation Math

@dynamic error;
@dynamic formula;
@dynamic input1;
@dynamic input2;
@dynamic input3;
@dynamic input4;

- (void)awake {
	[super awake];
	[self addObserver:self forKeyPath:@"formula" options:NSKeyValueObservingOptionPrior context:@"formula"];
}

- (void)willTurnIntoFault{
	[super  willTurnIntoFault];
	[self removeObserver:self forKeyPath:@"formula"];
}

- (NSArray*)orderdInputs{
	return [NSArray arrayWithObjects:@"input1", @"input2", @"input3", @"input4", nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if ([(__bridge NSString*)context isEqualToString:@"formula"])	{
		[self calculate];
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

-(void)calculate{
	NSDictionary *s = [NSDictionary dictionaryWithObjectsAndKeys:self.input1, @"input1", self.input2, @"input2", self.input3, @"input3", self.input4, @"input4", nil];
	NSError *error;
	NSNumber *number = [self.formula numberByEvaluatingStringWithSubstitutions:s error:&error];
	if (error) {
		self.error = [error localizedDescription];
	} else {
		self.output = number;
		self.error = nil;
	}
}


@end
