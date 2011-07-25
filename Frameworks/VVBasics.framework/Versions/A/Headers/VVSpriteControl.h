
#import <Cocoa/Cocoa.h>
#import "VVSpriteManager.h"




int					_maxSpriteControlCount;
int					_spriteControlCount;




@interface VVSpriteControl : NSControl {
	BOOL					deleted;
	VVSpriteManager			*spriteManager;
	BOOL					spritesNeedUpdate;
	NSEvent					*lastMouseEvent;
	NSColor					*clearColor;
	int						mouseDownModifierFlags;
	BOOL					mouseIsDown;
	NSView					*clickedSubview;	//	NOT RETAINED
}

- (void) generalInit;

- (void) prepareToBeDeleted;

- (void) finishedDrawing;

- (void) updateSprites;

@property (readonly) BOOL deleted;
@property (readonly) VVSpriteManager *spriteManager;
@property (assign, readwrite) BOOL spritesNeedUpdate;
- (void) setSpritesNeedUpdate;
@property (readonly) NSEvent *lastMouseEvent;
@property (retain,readwrite) NSColor *clearColor;
@property (readonly) BOOL mouseIsDown;

@end
