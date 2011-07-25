//
//  MyWindowController.m
//  Grains
//
//  Created by Daniel Kleinert on 28.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyWindowController.h"
#import "MyDocument.h"

@implementation MyWindowController

@synthesize objectsController, addObjectsController, mainSplitView, tabView, grainView, laceView, viewLoadRef, document;


- (void)windowDidLoad {
    [super windowDidLoad];
    
	NSArray *effects = [NSArray arrayWithObjects:@"Cloud", @"Random", @"FixedValue", @"Queue", @"OSCReceive", @"JavaScript", nil];
	
	// Populate AddController
	for (NSString* className in effects) {
		NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:className ,@"name", className, @"class", nil];
		[addObjectsController addObject:dict];
	}
	
	// bind Patchbay
    [laceView bind:@"dataObjects" toObject:objectsController withKeyPath:@"arrangedObjects.panel" options:nil];
	[laceView bind:@"selectionIndexes" toObject:objectsController withKeyPath:@"selectionIndexes" options:nil];
	
	// Load Controll Panels
	for (NSString* panelName in effects){
		if (![NSBundle loadNibNamed:panelName owner:self]) {
			NSLog(@"Error loading Nib for %@!", panelName);
		} else {
			NSTabViewItem* tabViewItem = [[NSTabViewItem alloc] initWithIdentifier:panelName];
			[tabViewItem setView:viewLoadRef];
			[tabView addTabViewItem:tabViewItem];
			viewLoadRef = nil;
		}
	}
}

- (void)dealloc {
	[laceView unbind:@"dataObjects"];
	[laceView unbind:@"selectionIndexes"];
}

-(void)addNewObject:(id)sender{
	NSString *entetyClass = [[addObjectsController selection] valueForKey:@"class"];
	Reseiver *newObject = [NSEntityDescription insertNewObjectForEntityForName:entetyClass inManagedObjectContext:[[self document] managedObjectContext]];
	
    NSManagedObject *newPanel = [NSEntityDescription insertNewObjectForEntityForName:@"Panel" inManagedObjectContext:[[self document] managedObjectContext]];
	[newPanel setValue:entetyClass forKey:@"title"];
    [newPanel setValue:newObject forKey:@"relatedObject"];
    
	NSUInteger index = 0;
    for (NSString* attribute in [newObject orderdInputs]){
        NSManagedObject* inputHole = [NSEntityDescription insertNewObjectForEntityForName:@"InputHole" inManagedObjectContext:[[self document] managedObjectContext]];
        [inputHole setValue:attribute forKey:@"label"];
		[inputHole setValue:attribute forKey:@"keyPath"];
		[inputHole setValue:[NSNumber numberWithUnsignedInt:index] forKey:@"position"];
        [inputHole setValue:newPanel forKey:@"data"];
		index++;
	}
    if (entetyClass != @"Cloud"){
        NSManagedObject *outputHole = [NSEntityDescription insertNewObjectForEntityForName:@"OutputHole" inManagedObjectContext:[[self document] managedObjectContext]];
        [outputHole setValue:@"out" forKey:@"label"];
        [outputHole setValue:newPanel forKey:@"data"];
    }
    
	[[[self document] mutableArrayValueForKey:@"objects"] addObject:newObject];
	[objectsController setSelectedObjects:[NSArray arrayWithObject: newObject]];
}

#pragma mark -
#pragma mark *** Toolbar ***

- (IBAction)ToggleView:(id)sender
{
	switch ([sender selectedSegment]) {
		case 0: // Grains
			grainView.enabled = [NSNumber numberWithBool:![grainView.enabled boolValue]];
			break;
		case 1: // Patchbay
			[laceView setHidden:![laceView isHidden]];
			break;
		case 2: // Attributes
			[mainSplitView
			 setPosition:[mainSplitView maxPossiblePositionOfDividerAtIndex:0]
			 ofDividerAtIndex:0
			 ];
			break;
	}
}

- (IBAction)TogglePlaybackControlls:(id)sender
{
	switch ([sender selectedSegment]) {
		case 0: // Play/Stop
			if ([sender isSelectedForSegment:[sender selectedSegment]]){
				
			} else {
				
			}
			break;
		case 1: // Record
			if ([sender isSelectedForSegment:[sender selectedSegment]]){
				[document startRecording];
			} else {
				[document stopRecording];
			}
			break;
	}
}

#pragma mark -
#pragma mark *** Vertical Splitview Delegate ***


- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)subview{
	if (splitView == mainSplitView) {
		// Only adjust size of the left splitview subview
		return [[[subview superview] subviews] objectAtIndex:0] == subview;
	} else {
		return YES;
	}
}

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview{
	// Make Pannel collapseable
	return [[[subview superview] subviews] objectAtIndex:1] == subview;
}


- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex{
	if (splitView == mainSplitView) {
		return proposedMax - 360;
	} else {
		return proposedMax - 100;
	}
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex{
	return (splitView == mainSplitView) ? 300 : 200;	
}

@end
