//
//  MeueController.h
//  Grains
//
//  Created by Daniel Kleinert on 05.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MeueController : NSObject {
		NSMenu __unsafe_unretained *exampleMenue;
}

@property (assign) IBOutlet NSMenu *exampleMenue;
- (IBAction)openExample:(id)sender;

@end
