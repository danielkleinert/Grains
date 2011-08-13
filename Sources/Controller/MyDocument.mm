//
//  MyDocument.m
//  Grains
//
//  Created by Daniel Kleinert on 02.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//



#import "MyDocument.h"
#import "Cloud.h"
#import "Reseiver.h"
#import "Panel.h"
#import "Connection.h"

NSString *GrainsPBoardType = @"GrainsPBoardType";

@implementation MyDocument

@synthesize clouds, windowController;

// doesn't work, dissable for now
//+ (BOOL)autosavesInPlace {return YES;}

- (id)init {
    self = [super init];
    if (self) {
		objects = [NSMutableArray arrayWithCapacity:20];
		clouds = [NSMutableArray arrayWithCapacity:10];
		
		// watch objects for clouds
		[self addObserver:self forKeyPath:@"objects" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
		
		// initialise Audio
		audio = [[Audio alloc] initWithDocument:self];
		[audio play];
    }
    return self;
}

-(BOOL)configurePersistentStoreCoordinatorForURL:(NSURL *)url ofType:(NSString *)fileType modelConfiguration:(NSString *)configuration storeOptions:(NSDictionary *)storeOptions error:(NSError **)error
{
    NSMutableDictionary *newOptions = [NSMutableDictionary dictionaryWithDictionary:storeOptions];
    [newOptions setValue:@"YES" forKey:NSMigratePersistentStoresAutomaticallyOption];
    [newOptions setValue:@"TRUE" forKey:NSInferMappingModelAutomaticallyOption];
	
    return [super configurePersistentStoreCoordinatorForURL:url ofType:fileType modelConfiguration:configuration storeOptions:newOptions error:error];
}

- (void)makeWindowControllers
{
    windowController = [[MyWindowController alloc] initWithWindowNibName:@"MyDocument"];
    [self addWindowController:windowController];
	
	// Reload saved Objects
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Reseiver" inManagedObjectContext:[self managedObjectContext]];
	[fetchRequest setEntity:entity];
	NSError *error = nil;
	NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
	if (fetchedObjects == nil) {
		NSLog(@"Fetch objects failed");
	}
	[[self mutableArrayValueForKey:@"objects"] addObjectsFromArray:fetchedObjects];
}

- (void)dealloc{
	[self removeObserver:self forKeyPath:@"objects"];
	[audio stop];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	// update clouds
	Reseiver* reseiver;
	switch ([[change valueForKey:NSKeyValueChangeKindKey] intValue]) {
		case NSKeyValueChangeInsertion:{
			for (reseiver in [change valueForKey:NSKeyValueChangeNewKey]) {
				if([reseiver isKindOfClass:[Cloud class]]) [[self mutableArrayValueForKey:@"clouds"] addObject:reseiver];
				[[self undoManager] registerUndoWithTarget:self selector:@selector(undoAddToObjects:) object:reseiver];
			}
			break;
		}
		case NSKeyValueChangeRemoval:{
			for (reseiver in [change valueForKey:NSKeyValueChangeOldKey]) {
				if([reseiver isKindOfClass:[Cloud class]]) [[self mutableArrayValueForKey:@"clouds"] removeObject:reseiver];
				[[self undoManager] registerUndoWithTarget:self selector:@selector(undoRemoveFromObjects:) object:reseiver];
			}
			break;
		}
		default:
			break;
	}
}
	
-(void)undoAddToObjects:(id)object{
	[[self mutableArrayValueForKey:@"objects"] removeObject:object];
}

-(void)undoRemoveFromObjects:(id)object{
	[[self mutableArrayValueForKey:@"objects"] addObject:object];
}

#pragma mark -
#pragma mark Audio

- (void)startRecording{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *urls = [fileManager URLsForDirectory:NSMusicDirectory inDomains:NSUserDomainMask];
	if ([urls count] > 0) {
		NSURL *exportFolderURL = [[urls objectAtIndex:0] URLByAppendingPathComponent:@"Grains/"];
		[fileManager createDirectoryAtURL:exportFolderURL withIntermediateDirectories:YES attributes:nil error:nil];
		UInt32 maxIndex = 0;
		for (NSURL* file in [fileManager contentsOfDirectoryAtURL:exportFolderURL includingPropertiesForKeys:nil options:nil error:nil]) {
			NSString *fileName = [file lastPathComponent];
			if ([fileName hasPrefix:@"Recording"]){
				NSCharacterSet *nunNumbers = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
				UInt32 index = [[fileName stringByTrimmingCharactersInSet:nunNumbers] intValue];
				if (index > maxIndex) maxIndex = index;
			}
		}
		NSString *newFileName = [NSString stringWithFormat:@"Recording %d.caf", maxIndex+1];
		NSURL *exportFileURL = [exportFolderURL URLByAppendingPathComponent:newFileName];
		[audio startRecordingToURL:exportFileURL];
	}
}

- (void)stopRecording{
	[audio stopRecording];
}

- (void)pauseAudio{
	[audio pause];
}

- (void)playAudio{
	[audio play];
}

- (void)setVolume:(float)volume{
	[audio setVolume:volume];
}

#pragma mark -
#pragma mark Copy / Paste / Cut / Delete

- (void)copy:sender {
    NSArray *selectedObjects = [[windowController objectsController] selectedObjects];
    NSUInteger count = [selectedObjects count];
    if (count == 0) {
        return;
    }
	
    NSMutableArray *copyObjectsArray = [NSMutableArray arrayWithCapacity:count];
	
    for (Reseiver *reseiver in selectedObjects) {
		NSMutableDictionary *addToCopyObjectsArray = [[NSMutableDictionary alloc] init];
		NSDictionary *objectAttributes = [reseiver dictionaryWithValuesForKeys:reseiver.entity.attributesByName.allKeys];
		NSDictionary *panelAttributes = [reseiver.panel dictionaryWithValuesForKeys:reseiver.panel.entity.attributesByName.allKeys];
		[addToCopyObjectsArray setObject:objectAttributes forKey:@"objectAttributes"];
		[addToCopyObjectsArray setObject:panelAttributes forKey:@"panelAttributes"];
		[addToCopyObjectsArray setObject:reseiver.entity.name forKey:@"entityName"];
		[addToCopyObjectsArray setObject:[[reseiver objectID] URIRepresentation] forKey:@"ID"];
		[copyObjectsArray addObject:addToCopyObjectsArray];
    }
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"Connection" inManagedObjectContext:[self managedObjectContext]]];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"sender IN %@ and reseiver in %@", selectedObjects, selectedObjects]];
	NSArray *connections = [[self managedObjectContext] executeFetchRequest:fetchRequest error:nil];

	for (Connection *connection in connections) {
		NSMutableDictionary *addToCopyObjectsArray = [[NSMutableDictionary alloc] init];
		NSDictionary *connectionAttributes = [connection dictionaryWithValuesForKeys:connection.entity.attributesByName.allKeys];
		[addToCopyObjectsArray setObject:connectionAttributes forKey:@"objectAttributes"];
		[addToCopyObjectsArray setObject:connection.entity.name forKey:@"entityName"];
		[addToCopyObjectsArray setObject:[[connection.sender objectID] URIRepresentation] forKey:@"sender"];
		[addToCopyObjectsArray setObject:[[connection.reseiver objectID] URIRepresentation] forKey:@"reseiver"];
        [copyObjectsArray addObject:addToCopyObjectsArray];
	}
	
    NSPasteboard *generalPasteboard = [NSPasteboard generalPasteboard];
    [generalPasteboard declareTypes: [NSArray arrayWithObjects:GrainsPBoardType, nil] owner:self];
    NSData *copyData = [NSKeyedArchiver archivedDataWithRootObject:copyObjectsArray];
    [generalPasteboard setData:copyData forType:GrainsPBoardType];
}

- (void)paste:sender {
    NSPasteboard *generalPasteboard = [NSPasteboard generalPasteboard];
    NSData *data = [generalPasteboard dataForType:GrainsPBoardType];
    if (data == nil) {
        return;
    }
	
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSArray *objectsArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	NSMutableArray *selectedObjects = [[NSMutableArray alloc] init];
	NSMutableDictionary *newReseiverForOldID = [[NSMutableDictionary alloc] init];
	
    for (NSDictionary *objectDict in objectsArray) {
        NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:[objectDict valueForKey:@"entityName"] inManagedObjectContext:moc];
        [object setValuesForKeysWithDictionary:[objectDict valueForKey:@"objectAttributes"]];
		if ([[objectDict valueForKey:@"entityName"] isEqualToString:@"Connection"]) {
			[object setValue:[newReseiverForOldID objectForKey:[objectDict valueForKey:@"sender"]] forKey:@"sender"];
			[object setValue:[newReseiverForOldID objectForKey:[objectDict valueForKey:@"reseiver"]] forKey:@"reseiver"];
			// tight coupling :/
			[windowController addLaceForConnection:(Connection *)object];
		} else {
			Panel *panel = [Panel newPanelForResiver:(Reseiver*)object inManagedObjectContext:[self managedObjectContext]];
			[panel setValuesForKeysWithDictionary:[objectDict valueForKey:@"panelAttributes"]];
			[newReseiverForOldID setObject:object forKey:[objectDict valueForKey:@"ID"]];
			[[self mutableArrayValueForKey:@"objects"] addObject:object];
			[selectedObjects addObject:object];
		}
    }
	[[windowController objectsController] setSelectedObjects:selectedObjects];
}

- (void)cut:sender {
    [self copy:sender];
	[windowController delete:sender];
}

#pragma mark -
#pragma mark Error handling

- (NSError *)willPresentError:(NSError *)inError {
	NSLog(@"Failed to save to data store: %@", [inError localizedDescription]);
	NSArray* detailedErrors = [[inError userInfo] objectForKey:NSDetailedErrorsKey];
	if(detailedErrors != nil && [detailedErrors count] > 0) {
		for(NSError* detailedError in detailedErrors) {
			NSLog(@"  DetailedError: %@", [detailedError userInfo]);
		}
	}
	else {
		NSDictionary* userInfo = [inError userInfo];
		NSLog(@"  %@", userInfo);
		//[[userInfo objectForKey:@"NSValidationErrorObject"] setValue:[NSNumber numberWithInt:10] forKey:[userInfo objectForKey:@"NSValidationErrorKey"]];
		return nil;
	}
	return inError;
}




@end
