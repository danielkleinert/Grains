//
//  GrainView.h
//  Grains
//
//  Created by Daniel Kleinert on 16.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/CoreAnimation.h>
#import "Cloud.h"

@interface GrainView : NSView {
@private
    CALayer* rootLayer;
	NSDictionary* propertyMap;
	NSNumber* enabled;
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx;
- (void)addGrainFromCloud:(Cloud*)cloud in:(NSNumber*)timeOffset;

@property(nonatomic, retain) NSNumber* enabled;

@end
