//
//  Reseiver.m
//  Grains
//
//  Created by Daniel Kleinert on 05.05.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Reseiver.h"
#import "Panel.h"
#import "Connection.h"


@implementation Reseiver
@dynamic panel;
@dynamic senderConnections;

- (void)awakeFromInsert {
    [super awakeFromInsert];
	[self awake];
}

- (void)awakeFromFetch {
    [super awakeFromFetch];
	[self awake];
}

- (void)awake {
	// easy to override in subclass
}


- (id)valueForUndefinedKey:(NSString *)key{
	// Suppress errors for bindings when an other object is selected
	return NSNotApplicableMarker;
}

- (void)update{
	for (Connection* senderConnection in self.senderConnections) {
		[senderConnection.sender update];
	}
}

- (NSArray*)orderdInputs{
	return [[[self.entity attributesByName] allKeys] sortedArrayUsingComparator:
			^(id obj1, id obj2) { 
				return [obj1 compare:obj2]; 
			}];
}

@end
