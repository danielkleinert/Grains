//
//  Cloud.m
//  Grains
//
//  Created by Daniel Kleinert on 31.03.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Cloud.h"

@implementation Cloud

@dynamic waveForm;
@dynamic audioFileUrl;
@dynamic audioFileOffset;

@dynamic intervall;
@dynamic duration;

@dynamic playbackRate;
@dynamic playbackRateVelocity;
@dynamic playbackRateAcceleration;

@dynamic gain;
@dynamic gainVelocity;
@dynamic gainAcceleration;

@dynamic pan;
@dynamic panVelocity;
@dynamic panAcceleration;

@dynamic envAttackForm;
@dynamic envAttack;
@dynamic envSustain;
@dynamic envReleaseForm;
@dynamic envRelease;

@synthesize validation;


+ (NSDictionary*)validation{
	static NSDictionary *cloudValidation;
	static dispatch_once_t cloudValidationPredicate;
	dispatch_once(&cloudValidationPredicate, ^{ 
		cloudValidation = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CloudValidation" ofType:@"plist"]]; 
	});
	return cloudValidation;
}

- (void)awakeFromInsert{
	[super awakeFromFetch];
	// init audifileurl
	self.waveForm = [NSNumber numberWithInt:0];
}

- (void)awake{
	validation = [Cloud validation];
	nextGrainCounter = 0;
	[self addObserver:self forKeyPath:@"waveForm" options:nil context:(void*)@"waveForm"];
}

- (void)dealloc{
	[self removeObserver:self forKeyPath:@"waveForm"];
}


- (BOOL)validateValue:(id *)ioValue forKey:(NSString *)key error:(NSError **)outError{
	NSNumber* value = *ioValue;
	NSNumber* min = [[validation objectForKey:key] objectForKey:@"min"];
	NSNumber* max = [[validation objectForKey:key] objectForKey:@"max"];
	if (min != nil && [value compare: min] == NSOrderedAscending) {
		*ioValue = min;
	}
	if (max != nil && [value compare: max] == NSOrderedDescending) {
		*ioValue = max;
	}
	return [super validateValue:ioValue forKey:key error:outError];
}

-(BOOL)validateEnvAttack:(id *)ioValue error:(NSError **)outError{
	if ([*ioValue floatValue] > [self.envRelease floatValue]) {
		self.envRelease = [NSNumber numberWithFloat:[*ioValue floatValue]];
	}
	return YES;
}

-(BOOL)validateEnvRelease:(id *)ioValue error:(NSError **)outError{
	if ([*ioValue floatValue] < [self.envAttack floatValue]) {
		self.envAttack = [NSNumber numberWithFloat:[*ioValue floatValue]];
	}
	return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if ([keyPath isEqualToString:@"waveForm"])	{
		switch ([self.waveForm intValue]) {
			case 0:
				self.audioFileUrl = [[NSBundle mainBundle] URLForResource:@"Sine1s" withExtension:@"aif"];
				break;
			case 1:
				self.audioFileUrl = [[NSBundle mainBundle] URLForResource:@"Square1s" withExtension:@"aif"];
				break;
			case 2:
				self.audioFileUrl = [[NSBundle mainBundle] URLForResource:@"Sawtooth1s" withExtension:@"aif"];
				break;				
			case 3:
				self.audioFileUrl = NULL;
				break;
		}
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (NSArray*)orderdInputs{
	return [NSArray arrayWithObjects:@"intervall", @"duration", @"audioFileOffset", @"playbackRate", @"playbackRateVelocity", @"playbackRateAcceleration", @"gain", @"gainVelocity", @"gainAcceleration", @"pan", @"panVelocity", @"panAcceleration", @"envAttack", @"envSustain", @"envRelease", nil];
}

@end


