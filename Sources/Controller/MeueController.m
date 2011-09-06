//
//  MeueController.m
//  Grains
//
//  Created by Daniel Kleinert on 05.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MeueController.h"

@implementation MeueController

@synthesize exampleMenue;

- (void)awakeFromNib{
	NSArray * examples = [[NSBundle mainBundle] pathsForResourcesOfType:@"grains" inDirectory:@""]; 
	for (NSString *example in examples) {
		NSString *name = [[[example lastPathComponent] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString: @"."]] objectAtIndex:0];
		NSMenuItem *menueItem = [[NSMenuItem alloc] initWithTitle:name action:@selector(openExample:) keyEquivalent:@""];
		[menueItem setTarget:self];
		[exampleMenue addItem:menueItem];
	}
}

- (void)openExample:(id)sender{
	NSURL *exampleURL = [[NSBundle mainBundle] URLForResource:[sender title] withExtension:@"grains"];
	NSError *error;
	NSDocument *document = [[NSDocumentController sharedDocumentController] openUntitledDocumentAndDisplay:YES error:&error];
	[document readFromURL:exampleURL ofType:@"SQLite" error:&error];
}

@end
