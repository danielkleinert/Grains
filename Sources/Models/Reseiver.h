//
//  Reseiver.h
//  Grains
//
//  Created by Daniel Kleinert on 05.05.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Panel;

@interface Reseiver : NSManagedObject {
@private
}

@property (nonatomic, retain) Panel * panel;
@property (nonatomic, retain) NSSet * senderConnections;

- (void)awake;

- (void)updateForRound:(int)round;
- (NSArray*)orderdInputs;

@end
