//
//  MyDocument.h
//  Grains
//
//  Created by Daniel Kleinert on 02.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MyWindowController.h"
#import "Audio.h"

@interface MyDocument : NSPersistentDocument {
	Audio* audio;
	NSMutableArray *objects;
	NSMutableArray *clouds;
}

@property (retain, readonly) NSMutableArray* clouds;
@property (retain, readonly) MyWindowController *windowController;

- (void)pauseAudio;
- (void)playAudio;
- (void)setVolume:(float)volume;
- (void)startRecording;
- (void)stopRecording;

@end
