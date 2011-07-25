//
//  ExponetialTransformer.h
//  Grains
//
//  Created by Daniel Kleinert on 24.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


// Maps through these points: (0,0), (1,max/2), (max,max)
@interface ExponetialTransformer : NSValueTransformer {
	NSNumber* maximum;
@private
	float half_max;
	float base;
}

@property(retain,nonatomic) NSNumber* maximum;

@end
