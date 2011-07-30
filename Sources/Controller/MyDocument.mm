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

@implementation MyDocument

@synthesize clouds, windowController;

+ (BOOL)autosavesInPlace {return YES;}

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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if ([keyPath isEqualToString:@"objects"]) {
		// update clouds
		Reseiver* reseiver;
		switch ([[change valueForKey:NSKeyValueChangeKindKey] intValue]) {
			case NSKeyValueChangeInsertion:{
				for (reseiver in [change valueForKey:NSKeyValueChangeNewKey]) {
					if([reseiver isKindOfClass:[Cloud class]]) [[self mutableArrayValueForKey:@"clouds"] addObject:reseiver];
					for (NSManagedObject* inputHole in reseiver.panel.inputs) {
						[inputHole addObserver:self forKeyPath:@"laces" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
					}
				}
				break;
			}
			case NSKeyValueChangeRemoval:{
				for (reseiver in [change valueForKey:NSKeyValueChangeOldKey]) {
					if([reseiver isKindOfClass:[Cloud class]]) [[self mutableArrayValueForKey:@"clouds"] removeObject:reseiver];
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
		NSManagedObject* inputHole = object;
		NSManagedObject* outputHole;
		switch ([[change valueForKey:NSKeyValueChangeKindKey] intValue]) {
			case NSKeyValueChangeInsertion:{
				for (outputHole in [change valueForKey:NSKeyValueChangeNewKey]) {
					NSManagedObject* connection = [NSEntityDescription insertNewObjectForEntityForName:@"Connection" inManagedObjectContext:self.managedObjectContext];
					[connection setValue:[inputHole valueForKeyPath:@"data.relatedObject"]  forKey:@"reseiver"];
					[connection setValue:[outputHole valueForKeyPath:@"data.relatedObject"] forKey:@"sender"];
					[connection setValue:[inputHole valueForKey:@"keyPath"] forKey:@"keyPath"];
				}
				break;
			}
			case NSKeyValueChangeRemoval:{
				for (outputHole in [change valueForKey:NSKeyValueChangeOldKey]) {
					NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
					NSEntityDescription *entity = [NSEntityDescription entityForName:@"Connection" inManagedObjectContext:self.managedObjectContext];
					[fetchRequest setEntity:entity];
					
					NSPredicate *predicate = [NSPredicate predicateWithFormat:@"reseiver = %@ and sender = %@ and keyPath = %@", [inputHole valueForKeyPath:@"data.relatedObject"], [outputHole valueForKeyPath:@"data.relatedObject"], [inputHole valueForKey:@"keyPath"]];
					[fetchRequest setPredicate:predicate];
					
					NSError *error = nil;
					NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
					if (fetchedObjects == nil) {
						NSLog(@"Fetch connection failed");
					}
					
					[self.managedObjectContext deleteObject:[fetchedObjects objectAtIndex:0]];
				}
				break;
			}
			default:
				break;
		}
	}
}

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
		[[userInfo objectForKey:@"NSValidationErrorObject"] setValue:[NSNumber numberWithInt:10] forKey:[userInfo objectForKey:@"NSValidationErrorKey"]];
		return nil;
	}
	return inError;
}




@end
