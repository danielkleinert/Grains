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
@synthesize manager;


- (void)awake {
	[super awake];
	self.manager = [GrainsOSCManager manager];
	[self addObserver:self forKeyPath:@"address" options:NSKeyValueObservingOptionPrior context:@"address"];
	[self startObservingOSCManager];
	
}

- (void)didTurnIntoFault
{
	[self stopObservingOSCManager];
	[self removeObserver:self forKeyPath:@"address"];
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
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (void)resivedOSCMeassage:(NSNotification *)notification{
	OSCMessage *message = [notification.userInfo objectForKey:@"message"];
	OSCValue *value = message.value;
	if (value.type == OSCValInt) {
		self.output = [NSNumber numberWithInt:[value intValue]];
	} else if(value.type == OSCValFloat) {
		self.output = [NSNumber numberWithFloat:[value floatValue]];
	}	  
}


@end
