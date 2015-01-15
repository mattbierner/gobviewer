#import <Cocoa/Cocoa.h>
#import <SceneKit/SceneKit.h>

@class Cmp;
@class Pal;
@class Tdo;

/**
    Previews 3DO file.
*/
@interface TdoView : SCNView

/**
    3DO to render.
*/
@property (nonatomic, strong) Tdo* tdo;

/**
    Color map used to render images.
*/
@property (nonatomic, strong) Cmp* cmp;

/**
    Palette to use for color
*/
@property (nonatomic, strong) Pal* pal;

@end
