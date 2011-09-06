//
//  OSCReceive.m
//  Grains
//
//  Created by Daniel Kleinert on 05.07.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OSCReceive.h"

@implementation OSCReceive
@dynamic address;
@dynamic index;
@synthesize manager;
@synthesize listenForNextAdress;


- (void)awake {
	[super awake];
	self.manager = [GrainsOSCManager manager];
	[self addObserver:self forKeyPath:@"address" options:NSKeyValueObservingOptionPrior context:@"address"];
	[self addObserver:self forKeyPath:@"listenForNextAdress" options:0 context:@"listenForNextAdress"];
	[self startObservingOSCManager];
	
}

- (void)didTurnIntoFault
{
	[self stopObservingOSCManager];
	[self removeObserver:self forKeyPath:@"address"];
	[self removeObserver:self forKeyPath:@"listenForNextAdress"];
    [super  didTurnIntoFault];
}

- (NSArray*)orderdInputs{
	return [[NSArray alloc] init];
}

-(void)startObservingOSCManager{
	if (self.address != nil) [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resivedOSCMeassage:) name:self.address object:[GrainsOSCManager manager]];
}

-(void)stopObservingOSCManager{
	if (self.address != nil) [[NSNotificationCenter defaultCenter] removeObserver:self name:self.address object:[GrainsOSCManager manager]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if ([(NSString*)objc_unretainedObject(context) isEqualToString:@"address"])	{
		if ([change objectForKey:NSKeyValueChangeNotificationIsPriorKey] == [NSNumber numberWithBool:YES]) {
			[self stopObservingOSCManager];
		} else {
			[self startObservingOSCManager];
		}
	} else if ([(NSString*)objc_unretainedObject(context) isEqualToString:@"listenForNextAdress"])	{
		if (listenForNextAdress) {
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resivedOSCMeassage:) name:nil object:[GrainsOSCManager manager]];
		} else {
			[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[GrainsOSCManager manager]];
			[self startObservingOSCManager];
		}
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (void)resivedOSCMeassage:(NSNotification *)notification{
	OSCMessage *message = [notification.userInfo objectForKey:@"message"];
	if (listenForNextAdress) {
		self.listenForNextAdress = NO;
		self.address = message.address;
	}
	self.output = [NSNumber numberWithFloat:[message calculateFloatValueAtIndex:self.index]];
	  
}


@end
