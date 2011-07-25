//
//  Random.h
//  Grains
//
//  Created by Daniel Kleinert on 05.05.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Effect.h"


@interface Random : Effect {
@private
}
@property (nonatomic, retain) NSNumber * min;
@property (nonatomic, retain) NSNumber * max;

@end
