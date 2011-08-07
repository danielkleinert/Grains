//
//  MyWindowController.m
//  Grains
//
//  Created by Daniel Kleinert on 28.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyWindowController.h"
#import "MyDocument.h"
#import "Panel.h"

@implementation MyWindowController

@synthesize objectsController, addObjectsController, mainSplitView, tabView, grainView, laceView, viewsToggle, viewLoadRef;


- (void)windowDidLoad {
    [super windowDidLoad];
    
	NSArray *effects = [NSArray arrayWithObjects:@"Cloud", @"Random", @"GausianRandom", @"FixedValue", @"Queue", @"Interpolate", @"OSCReceive", @"JavaScript", nil];
	
	// Populate AddController
	for (NSString* className in effects) {
		NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:className ,@"name", className, @"class", nil];
		[addObjectsController addObject:dict];
	}
	
	// bind Patchbay
    [laceView bind:@"dataObjects" toObject:objectsController withKeyPath:@"arrangedObjects.panel" options:nil];
	[laceView bind:@"selectionIndexes" toObject:objectsController withKeyPath:@"selectionIndexes" options:nil];
	
	// keep laces and connections in sync
	[self.document addObserver:self forKeyPath:@"objects" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
	
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
	[self.document removeObserver:self];
}


-(void)addNewObject:(id)sender{
	NSString *entetyClass = [[addObjectsController selection] valueForKey:@"class"];
	Reseiver *newObject = [NSEntityDescription insertNewObjectForEntityForName:entetyClass inManagedObjectContext:[[self document] managedObjectContext]];
	
	Panel *panel = [Panel newPanelForResiver:newObject inManagedObjectContext:[[self document] managedObjectContext]];
    
	[[[self document] mutableArrayValueForKey:@"objects"] addObject:newObject];
	[objectsController setSelectedObjects:[NSArray arrayWithObject: newObject]];
}

- (void)delete:sender {
	[objectsController remove:sender];
}

#pragma mark -
#pragma mark *** Toolbar ***

- (IBAction)toggleView:(id)sender
{
	switch ([sender selectedSegment]) {
		case 0: // Grains
			grainView.enabled = [NSNumber numberWithBool:![grainView.enabled boolValue]];
			break;
		case 1: // Patchbay
			[laceView setHidden:![laceView isHidden]];
			break;
		case 2: // Attributes
			CGFloat width;
			if ([sender isSelectedForSegment:[sender selectedSegment]]){
				width = uncollapsedSplitViewWidth;
			} else {
				width = [mainSplitView maxPossiblePositionOfDividerAtIndex:0];
			}
			[mainSplitView setPosition:width ofDividerAtIndex:0];
			break;
	}
}

- (IBAction)togglePlaybackControlls:(id)sender
{
	switch ([sender selectedSegment]) {
		case 0: // Play/Stop
			if ([sender isSelectedForSegment:[sender selectedSegment]]){
				[[self document] playAudio];
			} else {
				[[self document] pauseAudio];
			}
			break;
		case 1: // Record
			if ([sender isSelectedForSegment:[sender selectedSegment]]){
				[[self document] startRecording];
			} else {
				[[self document] stopRecording];
			}
			break;
	}
}

- (IBAction)setVolume:(id)sender{
	[(MyDocument*)[self document] setVolume:[(NSSlider*)sender floatValue]];
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

- (void)splitViewDidResizeSubviews:(NSNotification *)aNotification{
	if (aNotification.object == mainSplitView) {
		CGFloat width = [[[mainSplitView subviews] objectAtIndex:0] frame].size.width;
		if (width != [mainSplitView maxPossiblePositionOfDividerAtIndex:0]) {
			// if splitView was not collapsed save width for later uncollapsing
			uncollapsedSplitViewWidth = width;
			[viewsToggle setSelected:YES forSegment:2];
		} else {
			// if splitView was collapsed switch toggle state
			[viewsToggle setSelected:NO forSegment:2]; 
		}
	}	
}

#pragma mark -
#pragma mark *** Lace management ***

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if ([keyPath isEqualToString:@"objects"]) {
		Reseiver* reseiver;
		switch ([[change valueForKey:NSKeyValueChangeKindKey] intValue]) {
			case NSKeyValueChangeInsertion:{
				for (reseiver in [change valueForKey:NSKeyValueChangeNewKey]) {
					for (NSManagedObject* inputHole in reseiver.panel.inputs) {
						[inputHole addObserver:self forKeyPath:@"laces" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
					}
				}
				break;
			}
			case NSKeyValueChangeRemoval:{
				for (reseiver in [change valueForKey:NSKeyValueChangeOldKey]) {
					for (NSManagedObject* inputHole in reseiver.panel.inputs) {
						[inputHole removeObserver:self forKeyPath:@"laces"];
					}
				}
				break;
			}
			default:
				break;
		}
	} else {
		// update conections
		NSManagedObjectContext* context = [self.document managedObjectContext];
		NSManagedObject* inputHole = object;
		NSManagedObject* outputHole;
		switch ([[change valueForKey:NSKeyValueChangeKindKey] intValue]) {
			case NSKeyValueChangeInsertion:{
				for (outputHole in [change valueForKey:NSKeyValueChangeNewKey]) {
					Reseiver* sender = [outputHole valueForKeyPath:@"data.relatedObject"];
					Reseiver* reseiver = [inputHole valueForKeyPath:@"data.relatedObject"];
					NSString* keyPath = [inputHole valueForKey:@"keyPath"];
					
					// don't insert the same connection twice (paste -> addLace -> here)
					NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
					[fetchRequest setEntity:[NSEntityDescription entityForName:@"Connection" inManagedObjectContext:context]];
					[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"sender = %@ and reseiver = %@ and keyPath = %@", sender, reseiver, keyPath]];
					if ([[context executeFetchRequest:fetchRequest error:nil] count] == 0) {
						NSManagedObject* connection = [NSEntityDescription insertNewObjectForEntityForName:@"Connection" inManagedObjectContext:context];
						[connection setValue:reseiver  forKey:@"reseiver"];
						[connection setValue:sender forKey:@"sender"];
						[connection setValue:keyPath forKey:@"keyPath"];
					}
				}
				break;
			}
			case NSKeyValueChangeRemoval:{
				for (outputHole in [change valueForKey:NSKeyValueChangeOldKey]) {
					NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
					NSEntityDescription *entity = [NSEntityDescription entityForName:@"Connection" inManagedObjectContext:context];
					[fetchRequest setEntity:entity];
					
					NSPredicate *predicate = [NSPredicate predicateWithFormat:@"reseiver = %@ and sender = %@ and keyPath = %@", [inputHole valueForKeyPath:@"data.relatedObject"], [outputHole valueForKeyPath:@"data.relatedObject"], [inputHole valueForKey:@"keyPath"]];
					[fetchRequest setPredicate:predicate];
					
					NSError *error = nil;
					NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
					if (fetchedObjects == nil) {
						NSLog(@"Fetch connection failed");
					}
					
					[context deleteObject:[fetchedObjects objectAtIndex:0]];
				}
				break;
			}
			default:
				break;
		}
	}
}

- (void)addLaceForConnection:(Connection*)connection{
	NSManagedObject *sendHole = [connection.sender.panel.outputs anyObject];
	NSManagedObject *reseiveHole = [[connection.reseiver.panel.inputs filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"keyPath = %@", connection.keyPath]] anyObject];
	[laceView connectHole:sendHole toHole:reseiveHole];
}

@end
