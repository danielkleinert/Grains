//
//  OSCReceive.h
//  Grains
//
//  Created by Daniel Kleinert on 05.07.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Effect.h"
#import "GrainsOSCManager.h"


@interface OSCReceive : Effect {
	GrainsOSCManager *manager;
	BOOL listenForNextAdress;
@private
}
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) GrainsOSCManager *manager;
@property (nonatomic) BOOL listenForNextAdress;

-(void)startObservingOSCManager;
-(void)stopObservingOSCManager;

@end
