//
//  GausianRandom.h
//  Grains
//
//  Created by Daniel Kleinert on 02.08.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Effect.h"


@interface GausianRandom : Effect

@property (nonatomic) float mean;
@property (nonatomic) float deviation;
@property (nonatomic) float min;
@property (nonatomic) float max;
@property (nonatomic) BOOL clip;

@end
