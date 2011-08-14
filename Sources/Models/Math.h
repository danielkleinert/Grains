//
//  Math.h
//  Grains
//
//  Created by Daniel Kleinert on 14.08.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Effect.h"


@interface Math : Effect

@property (nonatomic, retain) NSString * error;
@property (nonatomic, retain) NSString * formula;
@property (nonatomic, retain) NSNumber * input1;
@property (nonatomic, retain) NSNumber * input2;
@property (nonatomic, retain) NSNumber * input3;
@property (nonatomic, retain) NSNumber * input4;

@end
