//
//  MyWindowController.h
//  Grains
//
//  Created by Daniel Kleinert on 28.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <EFLaceViewLib/EFLaceview.h>
#import "GrainView.h"
@class MyDocument;

@interface MyWindowController : NSWindowController {
	NSArrayController __unsafe_unretained *objectsController;
    NSArrayController __unsafe_unretained *addObjectsController;
	
	NSSplitView __unsafe_unretained *mainSplitView;
	NSTabView __unsafe_unretained *tabView;
	EFLaceView __unsafe_unretained *laceView;
	GrainView __unsafe_unretained *grainView;
	
	NSView __unsafe_unretained *viewLoadRef;
	
	MyDocument __unsafe_unretained *document;
}

@property (assign) IBOutlet NSArrayController* objectsController;
@property (assign) IBOutlet NSArrayController* addObjectsController;

@property (assign) IBOutlet NSSplitView* mainSplitView;
@property (assign) IBOutlet NSTabView* tabView;;
@property (assign) IBOutlet GrainView* grainView;
@property (assign) IBOutlet EFLaceView* laceView;;

@property (assign) IBOutlet NSView* viewLoadRef;
@property (assign) IBOutlet MyDocument* document;

-(void)addNewObject:(id)sender;

@end
