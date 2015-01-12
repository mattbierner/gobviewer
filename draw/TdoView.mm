#import "TdoView.h"

#import "Tdo.h"

@implementation TdoView

- (id) initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect options:nil])
    {
        self.allowsCameraControl = YES;
        self.autoenablesDefaultLighting = YES;
    }
    return self;
}

- (void) setTdo:(Tdo*)tdo
{
    _tdo = tdo;
    
    self.scene = [SCNScene scene];
    
    for (SCNGeometry* obj in [tdo createObjects])
    {
        SCNNode* node = [SCNNode nodeWithGeometry:obj];
        [self.scene.rootNode addChildNode:node];
    }
}

@end
