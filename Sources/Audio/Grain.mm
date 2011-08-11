//
//  Grain.m
//  Grains
//
//  Created by Daniel Kleinert on 12.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Grain.h"
#import "Audio.h"

@implementation Grain

@synthesize state;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithCloud:(Cloud*)theCloud in:(UInt32)frames {
    self = [super init];
    if (self) {
		
		cloud = theCloud;
		
		state = waiting;
		counter = frames;
		fileoffset = (SInt64)([theCloud.audioFileOffset floatValue] / 100.0 * theCloud->numberOfFrames);
		#warning dont hardcode samplerate
		duration = (UInt32)([theCloud.duration intValue] * 44100.0 / 1000);
		
		playbackSpeed = [theCloud.playbackSpeed floatValue];
		playbackSpeedVelocity = [theCloud.playbackSpeedVelocity floatValue];
		playbackSpeedAcceleration = [theCloud.playbackSpeedAcceleration floatValue];
		
		pan = [theCloud.pan floatValue];
		panVelocity = [theCloud.panVelocity floatValue];
		panAcceleration = [theCloud.panAcceleration floatValue];
		
		gain = [theCloud.gain floatValue];
		sustainStartFrame = [theCloud.envAttack unsignedIntValue] /100.0 *duration;
		attackForm = (waveForm)[theCloud.envAttackForm intValue];
		releaseStartFrame = [theCloud.envRelease unsignedIntValue] /100.0 *duration;
		releaseForm = (waveForm)[theCloud.envReleaseForm intValue];
    }
    return self;
}


-(NSString *) description {
    return [NSString stringWithFormat:@"State: %d, counter: %d",
            state, counter];
}

inline Float32 clamp(Float32 x, Float32 a, Float32 b){return x < a ? a : (x > b ? b : x);}

- (void)synthesizeAudioOf:(Audio*)audio to:(AudioQueueBufferRef)inCompleteAQBuffer{
	
	Float32* outBufferData = (Float32*)inCompleteAQBuffer->mAudioData;
	AudioBufferList tempBufferlist = audio->tempBufferList->GetModifiableBufferList();
	UInt32 framesToPlay = audio->framesPerBuffer;
	UInt32 controllRate = 10;
	
	switch (state) {
		case waiting:
			if (counter > framesToPlay) {
				counter -= framesToPlay;
				break;
			} else {
				framesToPlay -= counter;
				outBufferData += counter * audio->mDataFormat->mChannelsPerFrame;
				counter = duration;
				state = playing;
				// don't break - continue on to playing
			}
		case playing: {
			if (cloud->audioFileBuffer->GetNumBytes() > 0 ) {
				
				const Float32* audiofileData = (Float32*)cloud->audioFileBuffer->GetBufferList().mBuffers[0].mData;
				
				if (framesToPlay > counter) framesToPlay = counter;
				
				while (framesToPlay>0) {
					
					Float32 passed_time = (duration - counter) / (Float32)audio->mDataFormat->mSampleRate;
					Float32 actual_pan = clamp((panAcceleration / 2 * powf(passed_time,2) + panVelocity * passed_time + pan + 1) / 2 , 0, 1);
					Float32 actual_playbackRate = clamp(playbackSpeedAcceleration / 2 * powf(passed_time,2) + playbackSpeedVelocity * passed_time + playbackSpeed, 0.f, 100);
					actual_playbackRate = powf(30, (actual_playbackRate/50)-1);
					
					if (framesToPlay < controllRate ) controllRate = framesToPlay;
					
					Float32* envelope = (Float32*)tempBufferlist.mBuffers[0].mData;
					[self calculeteEnvelopeWithBuffer:envelope frames:controllRate];
					
					for(UInt32 i = 0; i<controllRate; i ++){
						UInt32 localFileoffset = (UInt32)(2*(fileoffset+i*actual_playbackRate)) % cloud->numberOfFrames;
						*outBufferData++ +=  audiofileData[localFileoffset] * *envelope++ * gain * (1 - actual_pan);
						*outBufferData++ +=  audiofileData[localFileoffset+1] * *envelope++ * gain * actual_pan;
					}
					counter -= controllRate;
					framesToPlay -= controllRate;
					fileoffset += controllRate * actual_playbackRate;
				
				}
			}
			if (counter <= 0) state=finished;
		}
		default:
			break;
	}
}

- (void)calculeteEnvelopeWithBuffer:(Float32*)buffer frames:(UInt32)frames {
	UInt32 upcounter = duration - counter;
	UInt32 bufferIndex = 0;
	// Attack
	for(; upcounter < sustainStartFrame && bufferIndex <= frames; bufferIndex++, upcounter++){
		Float32 normalizedZoneProgress = (Float32)upcounter/sustainStartFrame;
		switch (attackForm) {
			case linear:
				buffer[2*bufferIndex] = normalizedZoneProgress;
				buffer[2*bufferIndex+1] = normalizedZoneProgress;
				break;
			case sinuodial:
				buffer[2*bufferIndex] = sin(pi/2*normalizedZoneProgress);
				buffer[2*bufferIndex+1] = sin(pi/2*normalizedZoneProgress);
				break;
			case exponential:
				buffer[2*bufferIndex] = powf(1000, normalizedZoneProgress - 1);
				buffer[2*bufferIndex+1] = powf(1000, normalizedZoneProgress - 1);
				break;
		}
	}
	// Sustain
	for(; upcounter < releaseStartFrame && bufferIndex <= frames; bufferIndex++, upcounter++){
		buffer[2*bufferIndex] = 1;
		buffer[2*bufferIndex+1] = 1;
	}
	// Release
	for(; bufferIndex < frames; bufferIndex++, upcounter++){
		Float32 normalizedZoneProgress = (Float32)(upcounter-releaseStartFrame)/(duration-releaseStartFrame);
		switch (attackForm) {
			case linear:
				buffer[2*bufferIndex] = 1 - normalizedZoneProgress;
				buffer[2*bufferIndex+1] = 1 - normalizedZoneProgress;
				break;
			case sinuodial:
				buffer[2*bufferIndex] = cos(pi/2*normalizedZoneProgress);
				buffer[2*bufferIndex+1] = cos(pi/2*normalizedZoneProgress);
				break;
			case exponential:
				buffer[2*bufferIndex] = powf(1.0/1000, normalizedZoneProgress);
				buffer[2*bufferIndex+1] = powf(1.0/1000, normalizedZoneProgress);
				break;
		}
	}
}
 
@end



