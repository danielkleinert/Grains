//
//  GrainView.m
//  Grains
//
//  Created by Daniel Kleinert on 16.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GrainView.h"


@implementation GrainView

@synthesize enabled;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		self.enabled = [NSNumber numberWithBool:YES];
		
        CALayer* backgroundLayer = [CALayer layer];
		CGColorRef backgroundColor = CGColorCreateGenericRGB(0.1953125, 0.1953125, 0.1953125, 1);
		backgroundLayer.backgroundColor = backgroundColor;
		CGColorRelease(backgroundColor);
		backgroundLayer.frame = NSRectToCGRect(frame);
		[self setLayer:backgroundLayer];
		[self setWantsLayer:YES];
		
		rootLayer = [CALayer layer];
		[backgroundLayer addSublayer:rootLayer];
		rootLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
		rootLayer.frame = CGRectMake(10, 10, frame.size.width-20, frame.size.height-20);
		rootLayer.speed = 0.4f;
				
//		CIFilter *bloom = [CIFilter filterWithName:@"CIBloom"];
//		[bloom setDefaults];
//		[bloom setValue:[NSNumber numberWithFloat:5.0] forKey:@"inputRadius"];
//		[bloom setName:@"glow"];
//		[rootLayer setFilters:[NSArray arrayWithObject:bloom]];
		
		propertyMap = [NSDictionary dictionaryWithObjectsAndKeys:
					   @"pan", @"x",
					   @"playbackSpeed", @"y",
					   // NULL, @"size",
					   @"audioFileOffset", @"hue",
					   @"duration", @"saturation",
					   @"gain", @"brightness", 
					   nil];
    }
    
    return self;
}

inline float clamp(float x, float a, float b){return x < a ? a : (x > b ? b : x);}

- (NSArray*)valuesForLayerProperty:(NSString*)key andCloud:(Cloud*)cloud normalisedTo:(float)normelisation{
	NSMutableArray* returnValues = [NSMutableArray array];
	
	key = [propertyMap objectForKey:key];
	if (key == NULL) return 0;
	float propertyMin = [[[cloud.validation objectForKey:key] objectForKey:@"min"] floatValue];
	float propertyMax = [[[cloud.validation objectForKey:key] objectForKey:@"max"] floatValue];
	
	float initialValue = [[cloud valueForKeyPath:key] floatValue];
	float velocity, acceleration;
	id velocityObject = [cloud valueForKeyPath:[key stringByAppendingString:@"Velocity"]];
	if (velocityObject != NSNotApplicableMarker) {
		velocity = [velocityObject floatValue];
		acceleration = [[cloud valueForKeyPath:[key stringByAppendingString:@"Acceleration"]] floatValue];
	} else {
		velocity = acceleration = 0;
	}
	float duration = [cloud.duration floatValue] / 1000;
	float t = 0;
	while (t < duration) {
		float value = (acceleration / 2) * (float)pow(t,2) + (velocity * t) + initialValue;
		value = clamp(value, propertyMin, propertyMax);
		value = (value-propertyMin)/(propertyMax-propertyMin) * normelisation;
		[returnValues addObject:[NSNumber numberWithFloat:value]];
		t += 1./60.;
	}
	return returnValues;

}

- (void)addGrainFromCloud:(Cloud*)cloud in:(NSNumber*)timeOffset{
	if ([self.enabled boolValue]) {		
		CAShapeLayer* circleLayer = [CAShapeLayer layer];
		[rootLayer addSublayer:circleLayer];

		CGRect circleBounds = CGRectMake(0, 0, 20, 20);
		CGMutablePathRef circle = CGPathCreateMutable();
		CGPathAddEllipseInRect(circle, NULL, circleBounds);
		
		circleLayer.path = circle;
		circleLayer.frame = circleBounds;
		
		
		[CATransaction begin];
		[CATransaction setCompletionBlock:^{ [circleLayer removeFromSuperlayer]; }];
		CFTimeInterval beginTime = [circleLayer convertTime:CACurrentMediaTime()+[timeOffset doubleValue] fromLayer:nil];
		
		
		// Position
		
		NSArray* xAnimationValues = [self valuesForLayerProperty:@"x" andCloud:cloud normalisedTo:rootLayer.bounds.size.width];
		NSArray* yAnimationValues = [self valuesForLayerProperty:@"y" andCloud:cloud normalisedTo:rootLayer.bounds.size.height];
		float xEndPosition = [[xAnimationValues lastObject] floatValue];
		float yEndPosition = [[yAnimationValues lastObject] floatValue];
		circleLayer.position = CGPointMake(xEndPosition, yEndPosition);
		circleLayer.autoresizingMask = kCALayerMaxXMargin | kCALayerMaxYMargin | kCALayerMinXMargin | kCALayerMinYMargin;
		
		CAKeyframeAnimation* xAnimation = [CAKeyframeAnimation animation];
		xAnimation.keyPath = @"position.x";
		xAnimation.values = xAnimationValues;
		xAnimation.duration = [cloud.duration floatValue] / 1000;
		xAnimation.beginTime = beginTime;
		[circleLayer addAnimation:xAnimation forKey:@"xAnimation"];
		
		CAKeyframeAnimation* yAnimation = [CAKeyframeAnimation animation];
		yAnimation.keyPath = @"position.y";
		yAnimation.values = yAnimationValues;
		yAnimation.duration = [cloud.duration floatValue] / 1000;
		yAnimation.beginTime = beginTime; 
		[circleLayer addAnimation:yAnimation forKey:@"yAnimation"];
		
		
		// Color
		
		NSArray* hueAnimationValues = [self valuesForLayerProperty:@"hue" andCloud:cloud normalisedTo:1];
		NSArray* saturationAnimationValues = [self valuesForLayerProperty:@"saturation" andCloud:cloud normalisedTo:1];
		NSArray* brightnessAnimationValues = [self valuesForLayerProperty:@"brightness" andCloud:cloud normalisedTo:1];
		
		NSMutableArray* cgColorAnimationValues = [[NSMutableArray alloc] init];
		for(NSUInteger i=0; i < [hueAnimationValues count]; i++){
			NSColor* color = [NSColor colorWithDeviceHue:[[hueAnimationValues objectAtIndex:i] floatValue]
											  saturation:[[saturationAnimationValues objectAtIndex:i] floatValue]
											  brightness:[[brightnessAnimationValues objectAtIndex:i] floatValue]
												   alpha:1]; 
			[cgColorAnimationValues addObject:(id)objc_unretainedObject(CGColorCreateGenericRGB(color.redComponent, color.greenComponent, color.blueComponent, 1))];
		}
		
		circleLayer.fillColor = (CGColorRef)objc_unretainedPointer([cgColorAnimationValues lastObject]);
		CAKeyframeAnimation* colorAnimation = [CAKeyframeAnimation animation];
		colorAnimation.keyPath = @"fillColor";
		colorAnimation.values = cgColorAnimationValues;
		colorAnimation.duration = [cloud.duration floatValue] / 1000;
		colorAnimation.beginTime = beginTime;
		[circleLayer addAnimation:colorAnimation forKey:@"colorAnimation"];
		
		
		//	CAShapeLayer* motionBlurLayer = [CAShapeLayer layer];
		//	[circleLayer addSublayer:motionBlurLayer];
		//	motionBlurLayer.path = circleLayer.path;
		//	motionBlurLayer.fillColor = circleLayer.fillColor;
		//
		//	CIFilter *motionBlur = [CIFilter filterWithName:@"CIMotionBlur"];
		//	[motionBlur setDefaults];
		//	[motionBlur setValue:[NSNumber numberWithFloat:20.0] forKey:@"inputRadius"];
		//	motionBlurLayer.position = CGPointMake(-20,0);
		//	//[motionBlur setValue:[NSNumber numberWithFloat:5.0] forKey:@"inputAngle"];
		//	[motionBlur setName:@"motionBlur"];
		//	[motionBlurLayer setFilters:[NSArray arrayWithObject:motionBlur]];
		
		
		// Cleanup
		
		for(id color in cgColorAnimationValues){
			CGColorRelease((CGColorRef)objc_unretainedPointer(color));
		}
		CGPathRelease(circle);
		
		[CATransaction commit];
		
	}
}



- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
	NSGraphicsContext *nsGraphicsContext;
	nsGraphicsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:ctx flipped:NO];
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:nsGraphicsContext];
	
    // Set the color in the current graphics context for future draw operations
    [[NSColor blackColor] setStroke];
    [[NSColor redColor] setFill];
	
    // Create our circle path
    NSRect rect = NSMakeRect(0, 0, 20, 20);
    NSBezierPath* circlePath = [NSBezierPath bezierPath];
    [circlePath appendBezierPathWithOvalInRect: rect];
	
    // Outline and fill the path
    [circlePath stroke];
    [circlePath fill];
	
	[NSGraphicsContext restoreGraphicsState];
}

@end
