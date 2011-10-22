//
//  JavaScript.m
//  Grains
//
//  Created by Daniel Kleinert on 06.07.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "JavaScript.h"


@implementation JavaScript
@dynamic script;
@dynamic hasError;
@dynamic input1;
@dynamic input2;
@dynamic input3;
@dynamic input4;

+(WebScriptObject *)webScriptObject{
	static WebView *webView;
	static WebScriptObject* webScriptObject;
	static dispatch_once_t javaScriptPredicate;
	dispatch_once(&javaScriptPredicate, ^{ 
		webView = [[WebView alloc] init]; 
		[[webView mainFrame] loadHTMLString:@"" baseURL:NULL];
		webScriptObject = [webView windowScriptObject];
	});
	return webScriptObject;
}

- (void)awake {
	[super awake];
	[self addObserver:self forKeyPath:@"script" options:NSKeyValueObservingOptionPrior context:@"script"];	
}

- (void)didTurnIntoFault
{
	[self removeObserver:self forKeyPath:@"script"];
    [super  didTurnIntoFault];
}

- (NSArray*)orderdInputs{
	return [NSArray arrayWithObjects:@"input1", @"input2", @"input3", @"input4", nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if ([(__bridge NSString*)context isEqualToString:@"script"])	{
		[self calculate];
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

-(void)calculate{
	WebScriptObject* scriptObject = [JavaScript webScriptObject];
    [scriptObject setValue:self.input1 forKey:@"input1"];
	[scriptObject setValue:self.input2 forKey:@"input2"];
	[scriptObject setValue:self.input3 forKey:@"input3"];
	[scriptObject setValue:self.input4 forKey:@"input4"];
	id returnValue = [scriptObject evaluateWebScript:self.script]; 
	if ([returnValue isKindOfClass:[NSNumber class]]) {
		if (self.hasError != [NSNumber numberWithBool:NO]) self.hasError = [NSNumber numberWithBool:NO]; // don't get it dirtier than necessary
		self.output = returnValue;
	} else {
		if (self.hasError != [NSNumber numberWithBool:YES]) self.hasError = [NSNumber numberWithBool:YES];
	}
}

@end
