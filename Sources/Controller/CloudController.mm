//
//  CloudController.m
//  Grains
//
//  Created by Daniel Kleinert on 13.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CloudController.h"
#include <AudioToolbox/AudioToolbox.h>
#import "Cloud.h"


@implementation CloudController

- (IBAction)chooseWaveForm:(id)sender{
	if ([sender selectedSegment] == 3) {
		// chosen user-defined audio file
		NSArray *coreAudioExtensions;
		UInt32 propertySize;	
		propertySize = sizeof(coreAudioExtensions);
		AudioFileGetGlobalInfo(kAudioFileGlobalInfo_AllExtensions, 0, NULL, &propertySize, &coreAudioExtensions);	
		
		NSOpenPanel *oPanel = [NSOpenPanel openPanel];
		[oPanel setTitle:@"Choose Audiofile"];
		//int result = [oPanel runModalForDirectory:NSHomeDirectory() file:nil types:coreAudioExtensions];
		int result = [oPanel runModal];	
		if (result == NSOKButton) {
			NSURL* url = [oPanel URL];
			[[objectController selection] setValue:url forKey:@"audioFileUrl"];
		}
	}
}

@end
