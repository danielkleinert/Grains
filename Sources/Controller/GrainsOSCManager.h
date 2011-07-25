//
//  GrainsOSCManager.h
//  Grains
//
//  Created by Daniel Kleinert on 05.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <VVOSC/VVOSC.h>
#import <Foundation/Foundation.h>

@interface GrainsOSCManager : NSObject{
	OSCManager *manager;
	OSCInPort *inPort; 
}

+(GrainsOSCManager *)manager;
@property (nonatomic, retain) OSCInPort *inPort;


@end
