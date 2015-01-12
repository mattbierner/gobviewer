#import "TdoView.h"

#import "Tdo.h"

@implementation TdoView

- (id) initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect options:nil])
    {
        self.scene = [SCNScene scene];
        
        self.scene = self.scene;
        self.allowsCameraControl = YES;
        self.autoenablesDefaultLighting = YES;
    }
    return self;
}

- (void) setTdo:(Tdo *)tdo
{
    _tdo = tdo;
    for (SCNNode* child in self.scene.rootNode.childNodes)
        [child removeFromParentNode];
    
    for (SCNGeometry* obj in [tdo createObjects])
    {
        SCNNode* node = [SCNNode nodeWithGeometry:obj];
        [self.scene.rootNode addChildNode:node];
    }
}

@end
