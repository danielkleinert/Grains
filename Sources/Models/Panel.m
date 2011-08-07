//
//  EFFake.m
//  EFLaceView
//
//  Created by MacBook Pro ef on 06/08/06.
//  Copyright 2006 Edouard FISCHER. All rights reserved.
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//	-	Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//	-	Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//	-	Neither the name of Edouard FISCHER nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "Panel.h"
#import "Reseiver.h"

@implementation Panel

@dynamic width;
@dynamic verticalOffset;
@dynamic titleColor;
@dynamic title;
@dynamic tag;
@dynamic originY;
@dynamic height;
@dynamic originX;
@dynamic outputs;
@dynamic relatedObject;
@dynamic inputs;

+ (NSArray *)keysForNonBoundsProperties {
	static NSArray *keys = nil;
    if (!keys) {
		keys = [[NSArray alloc] initWithObjects:@"tag",@"inputs",@"outputs",@"title",@"titleColor",@"verticalOffset",@"originX",@"originY",@"width",@"height", nil];
    }
    return keys;
}

+ (id)newPanelForResiver:(Reseiver *)reseiver inManagedObjectContext:(NSManagedObjectContext *)context{
    Panel* panel = [NSEntityDescription insertNewObjectForEntityForName:@"Panel" inManagedObjectContext:context];
	[panel setValue:reseiver.entity.name forKey:@"title"];
	[panel setValue:reseiver forKey:@"relatedObject"];
	[panel setValue:[NSColor grayColor] forKey:@"titleColor"];
	NSUInteger index = 0;
	for (NSString* attribute in [reseiver orderdInputs]){
		NSManagedObject* inputHole = [NSEntityDescription insertNewObjectForEntityForName:@"InputHole" inManagedObjectContext:context];
		[inputHole setValue:attribute forKey:@"label"];
		[inputHole setValue:attribute forKey:@"keyPath"];
		[inputHole setValue:[NSNumber numberWithUnsignedInteger:index] forKey:@"position"];
		[inputHole setValue:panel forKey:@"data"];
		index++;
	}
	if (![reseiver.entity.name isEqualToString:@"Cloud"]){
		NSManagedObject *outputHole = [NSEntityDescription insertNewObjectForEntityForName:@"OutputHole" inManagedObjectContext:context];
		[outputHole setValue:@"out" forKey:@"label"];
		[outputHole setValue:panel forKey:@"data"];
	}
    return panel;
}


@end
