
#import <Cocoa/Cocoa.h>

@class Reseiver;

// The data provided to EFViews must have a KVC-KVO complient NSColor titleColor property, and a class property keysForNonBoundsProperties
// This class makes a bridge to a coreData entity

@interface Panel : NSManagedObject {
		
}
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSNumber * verticalOffset;
@property (nonatomic, retain) NSData * colorAsData;
//@property (nonatomic, retain) UNKNOWN_TYPE titleColor;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * tag;
@property (nonatomic, retain) NSNumber * originY;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSNumber * originX;
@property (nonatomic, retain) NSSet* outputs;
@property (nonatomic, retain) Reseiver * relatedObject;
@property (nonatomic, retain) NSSet* inputs;


+ (NSArray *)keysForNonBoundsProperties;

- (NSColor *)titleColor;
- (void)setTitleColor:(NSColor *)aColor;

@end
