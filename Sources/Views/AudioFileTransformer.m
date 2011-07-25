//
//  AudioFileHiddenTransformer.m
//  Grains
//
//  Created by Daniel Kleinert on 07.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioFileHiddenTransformer : NSValueTransformer
@end
@implementation AudioFileHiddenTransformer
+ (Class)transformedValueClass { return [NSNumber class]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
    return (value == nil) ? nil : [NSNumber numberWithBool:[value intValue] != 3];
}
@end


@interface AudioFileTransformer : NSValueTransformer
@end
@implementation AudioFileTransformer
+ (Class)transformedValueClass { return [NSString class]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
    return (value == nil) ? nil : [(NSURL*)value lastPathComponent];
}
@end