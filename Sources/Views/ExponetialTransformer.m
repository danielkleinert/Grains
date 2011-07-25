//
//  ExponetialTransformer.m
//  Grains
//
//  Created by Daniel Kleinert on 24.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ExponetialTransformer.h"

@implementation ExponetialTransformer

@synthesize maximum;

- (id)init
{
    self = [super init];
    if (self) {
        [self addObserver:self forKeyPath:@"maximum" options:0 context:NULL];
		self.maximum = [NSNumber numberWithFloat:30.0];
    }
    
    return self;
}

+ (Class)transformedValueClass { return [NSNumber class]; }
+ (BOOL)allowsReverseTransformation { return YES; }

- (id)transformedValue:(id)value {
	// 1 -> max/2
	return [NSNumber numberWithFloat:logf([value floatValue])/logf(base)+half_max];
}

- (id)reverseTransformedValue:(id)value {
	// max/2 -> 1
	return [NSNumber numberWithFloat:pow(base, [value floatValue]-half_max)];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	float max = [maximum floatValue];
	half_max = max/2;
	base = powf(max, 2.0/max);
}

@end
