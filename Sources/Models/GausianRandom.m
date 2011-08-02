//
//  GausianRandom.m
//  Grains
//
//  Created by Daniel Kleinert on 02.08.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#include <stdlib.h>
#include <math.h>

#import "GausianRandom.h"

float clip(float x, float a, float b);
float clip(float x, float a, float b){return x < a ? a : (x > b ? b : x);}

double gaussrand(void);
double gaussrand(void) {
	static double V1, V2, S;
	static int phase = 0;
	double X;
	if(phase == 0) {
		do {
			double U1 = (double)rand() / RAND_MAX;
			double U2 = (double)rand() / RAND_MAX;
			V1 = 2 * U1 - 1;
			V2 = 2 * U2 - 1;
			S = V1 * V1 + V2 * V2;
		} while(S >= 1 || S == 0);
		X = V1 * sqrt(-2 * log(S) / S);
	} else
		X = V2 * sqrt(-2 * log(S) / S);
	phase = 1 - phase;
	return X;
}


@implementation GausianRandom

@dynamic mean;
@dynamic deviation;
@dynamic min;
@dynamic max;
@dynamic clip;

- (NSArray*)orderdInputs{
	return [NSArray arrayWithObjects:@"mean", @"deviation", @"min", @"max", nil];
}

-(void)calculate{
	float result = gaussrand() * self.deviation + self.mean;
	if (self.clip) {result = clip(result, self.min, self.max);};
	self.output = [NSNumber numberWithFloat:result];
}


@end
