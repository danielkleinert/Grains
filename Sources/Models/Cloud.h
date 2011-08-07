//
//  Cloud.h
//  Grains
//
//  Created by Daniel Kleinert on 31.03.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Reseiver.h"

#import "CABufferList.h"

typedef enum {
	linear,
	sinuodial,
	exponential,
} waveForm;

@interface Cloud : Reseiver {
@private
	NSDictionary* validation;
	
@public
	// Audio related properties
	UInt32 nextGrainCounter;
	CABufferList* audioFileBuffer;
	UInt32 numberOfFrames;
}

@property (nonatomic, retain) NSNumber * waveForm;
@property (nonatomic, retain) NSURL * audioFileUrl;
@property (nonatomic, retain) NSNumber * audioFileOffset;
@property (nonatomic, retain) NSNumber * playbackRate;
@property (nonatomic, retain) NSNumber * envReleaseForm;
@property (nonatomic, retain) NSNumber * gainVelocity;
@property (nonatomic, retain) NSNumber * pan;
@property (nonatomic, retain) NSNumber * envAttack;
@property (nonatomic, retain) NSNumber * playbackRateVelocity;
@property (nonatomic, retain) NSNumber * panAcceleration;
@property (nonatomic, retain) NSNumber * intervall;
@property (nonatomic, retain) NSNumber * playbackRateAcceleration;
@property (nonatomic, retain) NSNumber * gain;
@property (nonatomic, retain) NSNumber * panVelocity;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSNumber * gainAcceleration;
@property (nonatomic, retain) NSNumber * envRelease;
@property (nonatomic, retain) NSNumber * envAttackForm;
@property (nonatomic, retain) NSNumber * envSustain;

@property(retain, readonly) NSDictionary *validation;

@end

