//
//  _DDFunctionContainer.h
//  DDMathParser
//
//  Created by Dave DeLong on 7/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDTypes.h"

@interface _DDFunctionContainer : NSObject

@property (nonatomic,copy) DDMathFunction function;
@property (nonatomic,readonly) NSSet *aliases;

+ (NSString *)normalizedAlias:(NSString *)alias;

- (id)initWithFunction:(DDMathFunction)f name:(NSString *)name;

- (void)addAlias:(NSString *)alias;
- (void)removeAlias:(NSString *)alias;
- (BOOL)containsAlias:(NSString *)alias;

@end
