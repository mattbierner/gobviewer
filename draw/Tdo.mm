#import "Tdo.h"

#import <SceneKit/SceneKit.h>

#import "Bitmap.h"
#import "Gob.h"
#import "Pal.h"

#include <numeric>
#include <fstream>

SCNVector3 operator-(const SCNVector3& a, const SCNVector3& b)
{
    return {
        a.x - b.x,
        a.y - b.y,
        a.z - b.z };
}

SCNVector3 cross(const SCNVector3& a, const SCNVector3& b)
{
    return {
       a.y * b.z - a.z * b.y,
       a.z * b.x - a.x * b.z,
       a.x * b.y - a.y * b.x};
}

SCNVector3 normalize(const SCNVector3& a)
{
    CGFloat length = sqrt(pow(a.x, 2) + pow(a.y, 2) + pow(a.z, 2));
	return {
        a.x / length,
        a.y / length,
        a.z / length };
}

SCNVector3 average(const SCNVector3& a, const SCNVector3& b)
{
    return {
        (a.x + b.x) / 2.0f,
        (a.y + b.y) / 2.0f,
        (a.z + b.z) / 2.0f };
}

SCNVector3 dfToScn(const Df::TdoVertex& vec)
{
    return { vec.x, vec.y, vec.z };
}

CGPoint dfToScn(const Df::TdoTextureVertex& vec)
{
    return { vec.y, vec.x }; // Note: flipped here
}

SCNVector3 getNormal(SCNVector3 a, SCNVector3 b, SCNVector3 c)
{
	SCNVector3 u =  b - a;
    SCNVector3 v = c - a;
    return normalize(cross(u, v));
}


@interface Tdo()

+ (SCNGeometrySource*) createNormalsSource:(const Df::TdoObject&)obj;
+ (SCNGeometrySource*) createNormalsForQuads:(const Df::TdoObject&)obj;
+ (SCNGeometrySource*) createNormalsForTriangles:(const Df::TdoObject&)obj;

+ (SCNGeometrySource*) createVertexSource:(const Df::TdoObject&)obj;
+ (SCNGeometrySource*) createQuadVertexSource:(const Df::TdoObject&)obj;
+ (SCNGeometrySource*) createTriangleVertexSource:(const Df::TdoObject&)obj;

+ (SCNGeometrySource*) createTextureSource:(const Df::TdoObject&)obj;
+ (SCNGeometrySource*) createQuadTextureSource:(const Df::TdoObject&)obj;
+ (SCNGeometrySource*) createTriangleTextureSource:(const Df::TdoObject&)obj;

+ (SCNGeometryElement*) createElement:(const Df::TdoObject&)obj;

@end


@implementation Tdo

+ (SCNGeometrySource*) createVertexSource:(const Df::TdoObject&)obj
{
    if (!obj.geometry.quads.empty())
        return [Tdo createQuadVertexSource:obj];
    else
        return [Tdo createTriangleVertexSource:obj];
}

+ (SCNGeometrySource*) createQuadVertexSource:(const Df::TdoObject&)obj
{
    auto verts = obj.geometry.verticies;
    
    std::vector<SCNVector3> data;
    data.reserve(6 * obj.geometry.quads.size());
    for (const auto& quad : obj.geometry.quads)
    {
        data.push_back(dfToScn(verts[quad.c]));
        data.push_back(dfToScn(verts[quad.b]));
        data.push_back(dfToScn(verts[quad.a]));
        
        data.push_back(dfToScn(verts[quad.a]));
        data.push_back(dfToScn(verts[quad.d]));
        data.push_back(dfToScn(verts[quad.c]));
    }
    
    return [SCNGeometrySource geometrySourceWithVertices:&data[0] count:data.size()];
}

+ (SCNGeometrySource*) createTriangleVertexSource:(const Df::TdoObject&)obj
{
    const auto& verts = obj.geometry.verticies;
    
    std::vector<SCNVector3> data;
    data.reserve(3 * obj.geometry.triangles.size());
    for (const auto& triangle : obj.geometry.triangles)
    {
        data.push_back(dfToScn(verts[triangle.c]));
        data.push_back(dfToScn(verts[triangle.b]));
        data.push_back(dfToScn(verts[triangle.a]));
    }
    
    return [SCNGeometrySource geometrySourceWithVertices:&data[0] count:data.size()];
}

+ (SCNGeometrySource*) createTextureSource:(const Df::TdoObject&)obj
{
    if (!obj.geometry.textureQuads.empty())
        return [Tdo createQuadTextureSource:obj];
    else if (!obj.geometry.textureTriangles.empty())
        return [Tdo createTriangleTextureSource:obj];
    else
        return nil;
}

+ (SCNGeometrySource*) createQuadTextureSource:(const Df::TdoObject&)obj
{
    auto verts = obj.geometry.textureVerticies;
    
    std::vector<CGPoint> data;
    data.reserve(6 * obj.geometry.textureQuads.size());
    for (const auto& quad : obj.geometry.textureQuads)
    {
        data.push_back(dfToScn(verts[quad.c]));
        data.push_back(dfToScn(verts[quad.b]));
        data.push_back(dfToScn(verts[quad.a]));
        
        data.push_back(dfToScn(verts[quad.a]));
        data.push_back(dfToScn(verts[quad.d]));
        data.push_back(dfToScn(verts[quad.c]));
    }
    
    return [SCNGeometrySource geometrySourceWithTextureCoordinates:&data[0] count:data.size()];
}

+ (SCNGeometrySource*) createTriangleTextureSource:(const Df::TdoObject&)obj
{
    const auto& verts = obj.geometry.textureVerticies;
    
    std::vector<CGPoint> data;
    data.reserve(3 * obj.geometry.textureTriangles.size());
    for (const auto& triangle : obj.geometry.textureTriangles)
    {
        data.push_back(dfToScn(verts[triangle.c]));
        data.push_back(dfToScn(verts[triangle.b]));
        data.push_back(dfToScn(verts[triangle.a]));
    }
    
    return [SCNGeometrySource geometrySourceWithTextureCoordinates:&data[0] count:data.size()];
}


+ (SCNGeometrySource*) createNormalsSource:(const Df::TdoObject&)obj
{
    if (!obj.geometry.quads.empty())
        return [Tdo createNormalsForQuads: obj];
    else if (!obj.geometry.triangles.empty())
        return [Tdo createNormalsForTriangles: obj];
    else
        return nil;
}

+ (SCNGeometrySource*) createNormalsForQuads:(const Df::TdoObject&)obj
{
    const auto& verts = obj.geometry.verticies;
    
    std::vector<SCNVector3> data(obj.geometry.quads.size() * 6);
    auto it = std::begin(data);
    for (const auto& quad : obj.geometry.quads)
    {
        auto a = dfToScn(verts[quad.a]);
        auto b = dfToScn(verts[quad.b]);
        auto c = dfToScn(verts[quad.c]);

        std::fill_n(it, 6, getNormal(c, b, a));
        it += 6;
    }
    return [SCNGeometrySource geometrySourceWithNormals:&data[0] count:data.size()];
}

+ (SCNGeometrySource*) createNormalsForTriangles:(const Df::TdoObject&)obj
{
    const auto& verts = obj.geometry.verticies;
    
    std::vector<SCNVector3> data(obj.geometry.triangles.size() * 3);
    auto it = std::begin(data);
    for (const auto& triangle : obj.geometry.triangles)
    {
        auto a = dfToScn(verts[triangle.a]);
        auto b = dfToScn(verts[triangle.b]);
        auto c = dfToScn(verts[triangle.c]);
        
        std::fill_n(it, 3, getNormal(c, b, a));
        it += 3;
    }
    return [SCNGeometrySource geometrySourceWithNormals:&data[0] count:data.size()];
}

+ (SCNGeometryElement*) createElement:(const Df::TdoObject&)obj
{
    bool isTriangle = obj.geometry.quads.empty();
    
    size_t numberPrimitives = (isTriangle ? obj.geometry.triangles.size() : obj.geometry.quads.size());
    
    std::vector<unsigned> indices(numberPrimitives * (isTriangle ? 3 : 6));
    std::iota(std::begin(indices), std::end(indices), 0);
    
    NSData* indexData = [NSData dataWithBytes:&indices[0] length:indices.size() * sizeof(unsigned)];

    return [SCNGeometryElement
        geometryElementWithData:indexData
        primitiveType:SCNGeometryPrimitiveTypeTriangles
        primitiveCount:(isTriangle ? numberPrimitives : numberPrimitives * 2)
        bytesPerIndex:sizeof(unsigned)];
}

+ (Tdo*) createForTdo:(Df::Tdo)tdo
{
    return [[Tdo alloc] initWithTdo:tdo];
}

- (id) initWithTdo:(Df::Tdo)tdo
{
   _tdo = tdo;
   return self;
}


- (SCNGeometry*) createObject:(NSUInteger)index
{
    const auto object = _tdo.GetObject(index);
    const auto geometry = object.geometry;
    
    SCNGeometrySource* vertexSource = [[self class] createVertexSource:object];
    SCNGeometrySource* normalSource = [[self class] createNormalsSource:object];
    SCNGeometrySource* textureSource = [[self class] createTextureSource:object];

    SCNGeometryElement* element = [[self class] createElement:object];

    NSMutableArray* sources = [NSMutableArray arrayWithObject:vertexSource];
    if (normalSource)
        [sources addObject:normalSource];
    if (textureSource)
        [sources addObject:textureSource];
    
    SCNGeometry* obj = [SCNGeometry geometryWithSources:sources elements:@[element]];
    
    SCNMaterial* material = [SCNMaterial material];
    material.doubleSided = YES;
    material.locksAmbientWithDiffuse = YES;
    material.transparencyMode = SCNTransparencyModeAOne;
   /* if (!geometry.quads.empty())
    {
        auto quad = geometry.quads[0];
        auto color = [self.pal getColor:quad.color];
        material.diffuse.contents = color;
    }
    else if (!geometry.triangles.empty())
    {
        auto triangle = geometry.triangles[0];
        auto color = [self.pal getColor:triangle.color];
        material.diffuse.contents = color;
    }*/
    if (object.texture >= 0)
    {
        NSString* textureName = [NSString stringWithUTF8String:_tdo.GetTexture(object.texture).c_str()];
        
        Gob* gob = [Gob createFromFile:[NSURL URLWithString:@"TEXTURES.GOB"]];
        Bitmap* bitmap = [Bitmap createFromGob:gob name:textureName pal:self.pal];
        NSImage* img = [bitmap getImage];//[NSImage imageNamed:@"check.jpg"];
        material.diffuse.contents = img;
    }
    material.ambient.contents = [NSColor whiteColor];
    [obj insertMaterial:material atIndex:0];
    
    return obj;
}

- (NSArray*) createObjects
{
    size_t numObjects = _tdo.GetObjectsCount();
    NSMutableArray* objs = [NSMutableArray arrayWithCapacity:numObjects];
    for (unsigned i = 0; i < numObjects; ++i)
        [objs addObject:[self createObject:i]];
    return objs;
}


@end
