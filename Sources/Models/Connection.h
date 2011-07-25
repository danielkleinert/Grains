//
//  Connection.h
//  Grains
//
//  Created by Daniel Kleinert on 14.05.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "Reseiver.h"
#import "Effect.h"

@interface Connection : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * keyPath;
@property (nonatomic, retain) Effect * sender;
@property (nonatomic, retain) Reseiver * reseiver;

@end
