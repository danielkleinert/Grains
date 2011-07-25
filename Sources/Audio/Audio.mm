//
//  Audio.m
//  Grains
//
//  Created by Daniel Kleinert on 06.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Audio.h"
#import "Grain.h"
#import "MyDocument.h"

#import "CAXException.h"

#import <objc/runtime.h>

static void AQBufferCallback(void* inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inCompleteAQBuffer) 
{
	Audio* audio = (Audio*)objc_unretainedObject(inUserData);
	
	Float32* outBuffer = (Float32*)inCompleteAQBuffer->mAudioData;
	memset(outBuffer, 0, inCompleteAQBuffer->mAudioDataBytesCapacity);
	
	// play Grains
	for (Grain* grain in audio.grains) {
		audio->tempBufferList->Reset();
		audio->tempBufferList->AllocateBuffers(inCompleteAQBuffer->mAudioDataBytesCapacity);
		[grain synthesizeAudioOf:audio to:inCompleteAQBuffer];
		if (grain.state == finished) [audio.grains performSelector:@selector(removeObject:) withObject:grain afterDelay:0];
	}
	
	// playback
	inCompleteAQBuffer->mAudioDataByteSize = inCompleteAQBuffer->mAudioDataBytesCapacity;
	AudioQueueEnqueueBuffer(inAQ, inCompleteAQBuffer,  0, NULL);
	
	// write to file
	if (audio->isRecording){
		AudioBufferList buffer;
		buffer.mNumberBuffers = 1;
		buffer.mBuffers[0].mData = outBuffer;
		buffer.mBuffers[0].mDataByteSize = inCompleteAQBuffer->mAudioDataBytesCapacity;
		buffer.mBuffers[0].mNumberChannels = 2;
		audio->recordingFile->Write(audio->framesPerBuffer, &buffer);
	}
	
	// enque new grains
	for(Cloud* cloud in audio->clouds){
		SInt32 frames = audio->framesPerBuffer;
		int startsIn = 0;
		while (frames > 0) {
			if (cloud->nextGrainCounter < frames) {
				startsIn += cloud->nextGrainCounter;
				[cloud update];
				Grain* grain = [[Grain alloc] initWithCloud:cloud in:startsIn];
				[[audio grains] addObject:grain];
				[audio->document.windowController.grainView addGrainFromCloud:cloud in:[NSNumber numberWithFloat:(float)startsIn/audio->mDataFormat->mSampleRate]];
				frames -= cloud->nextGrainCounter;
				cloud->nextGrainCounter = [cloud.intervall intValue] * audio->mDataFormat->mSampleRate / 1000;
			} else {
				cloud->nextGrainCounter -= frames;
				frames = 0;
			}
		}
	}
}


@implementation Audio

@synthesize clouds;
@synthesize grains;

- (id)initWithDocument:(MyDocument*)myDocument{
	self = [super init];
    if (self) {
		document = myDocument;
		clouds = document.clouds;
		[document addObserver:self forKeyPath:@"clouds" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
		grains = [NSMutableArray array];
		nextGrainCounters = [NSMutableDictionary dictionary];
		isRecording = NO;
		
		double sampleRate = 44100.0;
		UInt32 numChannels = 2;
		mDataFormat	= new CAStreamBasicDescription(sampleRate, numChannels, CAStreamBasicDescription::kPCMFormatFloat32, true);
		
		UInt32 bufferByteSize = 0x2000 * mDataFormat->mChannelsPerFrame;
		framesPerBuffer = mDataFormat->BytesToFrames(bufferByteSize);
		
		tempBufferList = CABufferList::New(*mDataFormat);
		
		OSStatus result = AudioQueueNewOutput(mDataFormat, AQBufferCallback, (void*)objc_unretainedPointer(self), CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &mQueue);
		if(result) NSLog(@"AudioQueueNew failed");
		
		for (int i = 0; i < kNumberBuffers; ++i) {
			result = AudioQueueAllocateBuffer(mQueue, bufferByteSize, &mBuffers[i]);
			if(result) NSLog(@"AudioQueueAllocateBuffer failed");
			AQBufferCallback ((void*)objc_unretainedPointer(self), mQueue, mBuffers[i]);
		}	
		
		// lets start playing now 
		result = AudioQueueStart(mQueue, NULL);
		if(result) NSLog(@"AudioQueueStart failed");
	}
	return self;
}


- (void)stop{
	[document removeObserver:self forKeyPath:@"clouds"];
	for (Cloud* cloud in clouds) {
		[cloud removeObserver:self forKeyPath:@"audioFileUrl"];
		[cloud removeObserver:self forKeyPath:@"intervall"];
	}
	OSStatus result = AudioQueueDispose(mQueue, true);
	if(result) NSLog(@"AudioQueueDispose(true) failed");
}

- (void)startRecordingToURL:(NSURL*)url{
	recordingFile = new CAExtAudioFile();
	// Can't find corect formating for anything other than caf
	// CAStreamBasicDescription* fileFormat = new CAStreamBasicDescription(mDataFormat->mSampleRate, mDataFormat->mChannelsPerFrame, CAStreamBasicDescription::kPCMFormatFixed824, false);
	recordingFile->CreateWithURL((CFURLRef)objc_unretainedPointer(url), kAudioFileCAFType, *mDataFormat, NULL /* ChannelLayout */, kAudioFileFlags_EraseFile /* Flags */);
	// recordingFile->SetClientFormat(*mDataFormat);
	isRecording = YES;
}

- (void)stopRecording{
	isRecording = NO;
	recordingFile->Close();
	delete recordingFile;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if ([keyPath isEqualToString:@"clouds"]) {
		Cloud* cloud;
		switch ([[change valueForKey:NSKeyValueChangeKindKey] intValue]) {
			case NSKeyValueChangeInsertion:{
				for (cloud in [change valueForKey:NSKeyValueChangeNewKey]) {
					[cloud addObserver:self forKeyPath:@"audioFileUrl" options:0 context:NULL];
					[cloud addObserver:self forKeyPath:@"intervall" options:0 context:NULL];
					cloud->audioFileBuffer = CABufferList::New(*mDataFormat);
					[self openAudioFileOfCloud:cloud];
					
				}
				break;
			}
			case NSKeyValueChangeRemoval:{
				for (cloud in [change valueForKey:NSKeyValueChangeOldKey]) {
					[cloud removeObserver:self forKeyPath:@"audioFileUrl"];
					[cloud removeObserver:self forKeyPath:@"intervall"];
					//delete cloud->audioFileBuffer;
				}
				break;
			}
			default:
				break;
		}
		
	} else if ([keyPath isEqualToString:@"intervall"]) {
		Cloud * cloud = object;
		#warning account for passed time
		//int passedTime = [self.intervall intValue] - nextGrainCounter;
		cloud->nextGrainCounter = [cloud.intervall intValue] * mDataFormat->mSampleRate / 1000;
	} else if ([keyPath isEqualToString:@"audioFileUrl"]) {
		Cloud * cloud = object;
		[self openAudioFileOfCloud:cloud];
	} 
}

- (void)openAudioFileOfCloud:(Cloud*)cloud{
	if (cloud.audioFileUrl != NULL) {
		CAExtAudioFile* audioFile = new CAExtAudioFile();
		audioFile->OpenURL((CFURLRef)objc_unretainedPointer(cloud.audioFileUrl));
		audioFile->SetClientFormat(*mDataFormat);
		cloud->numberOfFrames = audioFile->GetNumberFrames();
		cloud->audioFileBuffer->AllocateBuffers(mDataFormat->FramesToBytes(cloud->numberOfFrames));
		audioFile->Read(cloud->numberOfFrames, &cloud->audioFileBuffer->GetModifiableBufferList());
		
	}
}


@end





