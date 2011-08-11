//
//  Grain.h
//  Grains
//
//  Created by Daniel Kleinert on 12.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "CAExtAudioFile.h"
#import "CABufferList.h"

#import "Cloud.h"

@class Audio;

enum GrainState {
	waiting, playing, finished	
};

@interface Grain : NSObject {

@public	
	Cloud* cloud;
	
	enum GrainState state;
	UInt32 counter;
	SInt64 fileoffset;
	UInt32 duration;
	
	Float32 playbackSpeed;
	Float32 playbackSpeedVelocity;
	Float32 playbackSpeedAcceleration;
	
	Float32 pan;
	Float32 panVelocity;
	Float32 panAcceleration;
	
	Float32 gain;
	UInt32 sustainStartFrame;
	waveForm attackForm;
	UInt32 releaseStartFrame;
	waveForm releaseForm;
	
}

@property (readonly) enum GrainState state;

- (id)initWithCloud:(Cloud*)cloud in:(UInt32)frames;

- (void)synthesizeAudioOf:(Audio*)audio to:(AudioQueueBufferRef)inCompleteAQBuffer;
- (void)calculeteEnvelopeWithBuffer:(Float32*)buffer frames:(UInt32)frames;

@end
