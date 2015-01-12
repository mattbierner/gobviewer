#import <Cocoa/Cocoa.h>

#import <SceneKit/SceneKit.h>

@class Tdo;


@interface TdoView : SCNView

@property (nonatomic, strong) SCNScene* scene;
@property (nonatomic, strong) Tdo* tdo;

@end
