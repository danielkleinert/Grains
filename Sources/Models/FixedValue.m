//
//  FixedValue.m
//  Grains
//
//  Created by Daniel Kleinert on 04.07.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FixedValue.h"


@implementation FixedValue
@dynamic sliderMin;
@dynamic sliderMax;


- (NSArray*)orderdInputs{
	return [[NSArray alloc] init];
}

-(void)calculate{
	self.output = self.value;
}


@end
