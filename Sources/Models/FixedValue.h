//
//  FixedValue.h
//  Grains
//
//  Created by Daniel Kleinert on 04.07.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Effect.h"


@interface FixedValue : Effect {
@private
}
@property (nonatomic, retain) NSNumber * sliderMin;
@property (nonatomic, retain) NSNumber * sliderMax;

@end
