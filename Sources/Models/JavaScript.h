//
//  JavaScript.h
//  Grains
//
//  Created by Daniel Kleinert on 06.07.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Effect.h"
#import <WebKit/WebKit.h>

@interface JavaScript : Effect {
@private
}
@property (nonatomic, retain) NSString * script;
@property (nonatomic, retain) NSNumber * hasError;
@property (nonatomic, retain) NSNumber * input1;
@property (nonatomic, retain) NSNumber * input2;
@property (nonatomic, retain) NSNumber * input3;
@property (nonatomic, retain) NSNumber * input4;

@end
