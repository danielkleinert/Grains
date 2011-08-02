//
//  GrainsOSCManager.m
//  Grains
//
//  Created by Daniel Kleinert on 05.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GrainsOSCManager.h"

@implementation GrainsOSCManager

@synthesize inPort;
@synthesize myIPAddress;

- (id)init
{
    self = [super init];
    if (self) {
        manager = [[OSCManager alloc] init];
		manager.delegate = self;
		inPort = [manager createNewInput];
		[self calculateMyIPAddress];
    }
    return self;
}

+(GrainsOSCManager *)manager{
	static GrainsOSCManager *manager;
	static dispatch_once_t grainOSCManagerPredicate;
	dispatch_once(&grainOSCManagerPredicate, ^{ 
		manager = [[GrainsOSCManager alloc] init]; 
	});
	return manager;
}

- (void)calculateMyIPAddress {
	NSOperationQueue* queue = [[NSOperationQueue alloc] init];
	[queue addOperationWithBlock:^{
		NSString* IPAddress;
		NSCharacterSet* charSet = [NSCharacterSet characterSetWithCharactersInString:@"abcdefABCDEF:%"];
		for(NSString *address in [[NSHost currentHost] addresses]){
			NSRange charSetRange = [address rangeOfCharacterFromSet:charSet];
			if ((charSetRange.length==0) && (charSetRange.location==NSNotFound))	{
				if (![address isEqualToString:@"127.0.0.1"])
					IPAddress = address;
			}
		}
		myIPAddress = @"127.0.0.1";
		[[NSOperationQueue mainQueue] addOperationWithBlock:^{
			self.myIPAddress = IPAddress;
		}];
	}];
}

- (NSString *) inPortLabelBase{
	return @"Grains";
}

- (void) receivedOSCMessage:(OSCMessage *)m	{
	NSDictionary * userInfo = [NSDictionary dictionaryWithObject:m forKey:@"message"];
	[[NSNotificationCenter defaultCenter] postNotificationName:m.address object:self userInfo:userInfo];
}

@end
