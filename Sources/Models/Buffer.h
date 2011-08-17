//
//  Buffer.h
//  Grains
//
//  Created by Daniel Kleinert on 16.08.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Effect.h"


@interface Buffer : Effect {
	int grainCounter;
	NSTimeInterval refreshTime;
}

@property (nonatomic, retain) NSNumber *input;
@property (nonatomic, retain) NSNumber *mode;
@property (nonatomic, retain) NSNumber *grains;
@property (nonatomic, retain) NSNumber *milliseconds;

@end
