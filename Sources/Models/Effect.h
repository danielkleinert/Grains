//
//  Effect.h
//  Grains
//
//  Created by Daniel Kleinert on 14.05.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Reseiver.h"

@class Connection;

@interface Effect : Reseiver {
@private
	NSNumber* output;
}
@property (nonatomic, retain) NSSet* reseiverConections;
@property (nonatomic, retain) NSNumber* output;

-(void)update;
-(void)calculate;

@end
