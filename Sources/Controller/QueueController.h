//
//  QueueController.h
//  Grains
//
//  Created by Daniel Kleinert on 04.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface QueueController : NSViewController {
	NSTokenField *tokenField; 
}

@property(retain) IBOutlet NSTokenField *tokenField;

@end