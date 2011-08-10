//
//  Interpolate.h
//  Grains
//
//  Created by Daniel Kleinert on 28.07.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Effect.h"


@interface Interpolate : Effect

@property (nonatomic) float from;
@property (nonatomic) float to;
@property (nonatomic) float duration;
@property (nonatomic) BOOL autoReverse;

@end
