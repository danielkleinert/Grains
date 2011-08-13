//
//  Effect.m
//  Grains
//
//  Created by Daniel Kleinert on 14.05.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Effect.h"
#import "Connection.h"


@implementation Effect
@dynamic reseiverConections;
@synthesize output;


- (void)awake {
	[self addObserver:self forKeyPath:@"output" options:0 context:@"output"];
}

- (void)didTurnIntoFault
{
	[self removeObserver:self forKeyPath:@"output"];
    [super  didTurnIntoFault];
}



- (void)addReseiverConectionsObject:(Connection *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"reseiverConections" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"reseiverConections"] addObject:value];
    [self didChangeValueForKey:@"reseiverConections" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
}

- (void)removeReseiverConectionsObject:(Connection *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"reseiverConections" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"reseiverConections"] removeObject:value];
    [self didChangeValueForKey:@"reseiverConections" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
}

- (void)addReseiverConections:(NSSet *)value {    
    [self willChangeValueForKey:@"reseiverConections" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"reseiverConections"] unionSet:value];
    [self didChangeValueForKey:@"reseiverConections" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeReseiverConections:(NSSet *)value {
    [self willChangeValueForKey:@"reseiverConections" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"reseiverConections"] minusSet:value];
    [self didChangeValueForKey:@"reseiverConections" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if ([(NSString*)objc_unretainedObject(context) isEqualToString:@"output"])	{
		for (Connection* reseiverConnection in self.reseiverConections) {
			NSNumber* value = [NSNumber numberWithFloat:[output floatValue]];
			[reseiverConnection.reseiver validateValue:&value forKey:reseiverConnection.keyPath error:NULL];
			[reseiverConnection.reseiver setValue:value forKey:reseiverConnection.keyPath];
		}
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

-(void)update{
	[super update];
	[[self managedObjectContext] processPendingChanges];
	[[[self managedObjectContext] undoManager] disableUndoRegistration];
	[self calculate];
	[[self managedObjectContext] processPendingChanges];
	[[[self managedObjectContext] undoManager] enableUndoRegistration];
}

-(void)calculate{}


@end
