#import "TdoView.h"

@implementation TdoView

- (id) initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect options:nil])
    {
        self.scene = [SCNScene scene];
        
        self.scene = self.scene;
        self.allowsCameraControl = YES;
        self.autoenablesDefaultLighting = YES;
        
        SCNBox* boxGeometry = [SCNBox boxWithWidth:10 height:10 length:10 chamferRadius:1.0];
        SCNNode* boxNode = [SCNNode nodeWithGeometry:boxGeometry];
        [self.scene.rootNode addChildNode:boxNode];
        
    }
    return self;
}

@end
