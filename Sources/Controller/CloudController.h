//
//  CloudController.h
//  Grains
//
//  Created by Daniel Kleinert on 13.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CloudController : NSViewController {
	IBOutlet NSObjectController* objectController;
	IBOutlet NSSlider* playBackRateSlider;
@private
    
}

- (IBAction)chooseWaveForm:(id)sender;

@end
