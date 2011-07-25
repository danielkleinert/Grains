//
//  QueueController.m
//  Grains
//
//  Created by Daniel Kleinert on 04.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "QueueController.h"

@implementation QueueController

@synthesize tokenField;

- (void)awakeFromNib{
	// only allow numbers of format 14.345
	NSMutableCharacterSet* tokenizingChars = [NSMutableCharacterSet decimalDigitCharacterSet];
	[tokenizingChars addCharactersInString:@".-"];
	// dont show empty textfield on double return !?!?
	[tokenizingChars formUnionWithCharacterSet: [NSCharacterSet symbolCharacterSet]];
	[tokenizingChars invert];
	[self.tokenField setTokenizingCharacterSet:tokenizingChars]; 
}

- (id)tokenField:(NSTokenField *)tokenField representedObjectForEditingString:(NSString *)editingString{
	NSScanner* scanner  = [NSScanner scannerWithString:editingString];
	float number = 0;
	[scanner scanFloat:&number];
	return [NSNumber numberWithFloat:number];	
}

- (NSString *)tokenField:(NSTokenField *)tokenField displayStringForRepresentedObject:(id)representedObject {
	return [(NSNumber*)representedObject stringValue];
}

@end
