//
//  Audio.h
//  Grains
//
//  Created by Daniel Kleinert on 06.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>

#import "CAStreamBasicDescription.h"
#import "CABufferList.h"
#import "CAExtAudioFile.h"

#import "Cloud.h"

@class Grain;
@class MyDocument;

#define kNumberBuffers 3


@interface Audio : NSObject {
	
@public	
	
	CAStreamBasicDescription 			*mDataFormat;
	AudioQueueRef						mQueue;
	AudioQueueBufferRef					mBuffers[kNumberBuffers];
	UInt32								framesPerBuffer;
	CABufferList 						*tempBufferList;
	float								volume;
	int									round;
	
	MyDocument __unsafe_unretained 		*document;
	NSMutableArray 					 	*clouds;
	NSMutableArray						*grains;
	
	NSMutableDictionary					*nextGrainCounters;
	
	CAExtAudioFile						*recordingFile;
	Boolean								isRecording;
	
}

@property (nonatomic, retain) NSArray* clouds;
@property (nonatomic, retain, readonly) NSMutableArray* grains;

- (id)initWithDocument:(MyDocument*)myDocument;
- (void)play;
- (void)pause;
- (void)stop;

- (void)setVolume:(float)volume;
	
- (void)openAudioFileOfCloud:(Cloud*)cloud;

- (void)startRecordingToURL:(NSURL*)url;
- (void)stopRecording;

@end



