#import "Tdo.h"

#import <SceneKit/SceneKit.h>

#import "Pal.h"

#include <numeric>

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

SCNVector3 dfToScn(const DF::TdoVertex& vec)
{
    return { vec.x, vec.y, vec.z };
}

SCNVector3 getNormal(SCNVector3 a, SCNVector3 b, SCNVector3 c)
{
	SCNVector3 u =  b - a;
    SCNVector3 v = c - a;
    return normalize(cross(u, v));
}


@interface Tdo()

+ (SCNGeometrySource*) createNormalsSource:(const DF::TdoObject&)obj;
+ (SCNGeometrySource*) createNormalsForQuads:(const DF::TdoObject&)obj;
+ (SCNGeometrySource*) createNormalsForTriangles:(const DF::TdoObject&)obj;

+ (SCNGeometrySource*) createVertexSource:(const DF::TdoObject&)obj;
+ (SCNGeometrySource*) createQuadVertexSource:(const DF::TdoObject&)obj;
+ (SCNGeometrySource*) createTriangleVertexSource:(const DF::TdoObject&)obj;

+ (SCNGeometryElement*) createElement:(const DF::TdoObject&)obj;

@end


@implementation Tdo

+ (SCNGeometrySource*) createVertexSource:(const DF::TdoObject&)obj
{
    if (!obj.geometry.quads.empty())
        return [Tdo createQuadVertexSource:obj];
    else
        return [Tdo createTriangleVertexSource:obj];
}

+ (SCNGeometrySource*) createQuadVertexSource:(const DF::TdoObject&)obj
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

+ (SCNGeometrySource*) createTriangleVertexSource:(const DF::TdoObject&)obj
{
    const auto& verts = obj.geometry.verticies;
    
    std::vector<SCNVector3> data;
    data.reserve(3 * obj.geometry.triangles.size());
    for (const auto& triangle : obj.geometry.triangles)
    {
        data.push_back(dfToScn(verts[triangle.a]));
        data.push_back(dfToScn(verts[triangle.b]));
        data.push_back(dfToScn(verts[triangle.c]));
    }
    
    return [SCNGeometrySource geometrySourceWithVertices:&data[0] count:data.size()];
}

+ (SCNGeometrySource*) createNormalsSource:(const DF::TdoObject&)obj
{
    if (!obj.geometry.quads.empty())
        return [Tdo createNormalsForQuads: obj];
    else
        return [Tdo createNormalsForTriangles: obj];
}

+ (SCNGeometrySource*) createNormalsForQuads:(const DF::TdoObject&)obj
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

+ (SCNGeometrySource*) createNormalsForTriangles:(const DF::TdoObject&)obj
{
    const auto& verts = obj.geometry.verticies;
    
    std::vector<SCNVector3> data(obj.geometry.triangles.size() * 3);
    auto it = std::begin(data);
    for (const auto& triangle : obj.geometry.triangles)
    {
        auto a = dfToScn(verts[triangle.a]);
        auto b = dfToScn(verts[triangle.b]);
        auto c = dfToScn(verts[triangle.c]);
        
        std::fill_n(it, 3, getNormal(a, b, c));
        it += 3;
    }
    return [SCNGeometrySource geometrySourceWithNormals:&data[0] count:data.size()];
}

+ (SCNGeometryElement*) createElement:(const DF::TdoObject&)obj
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

+ (Tdo*) createForTdo:(DF::Tdo)tdo
{
    return [[Tdo alloc] initWithTdo:tdo];
}

- (id) initWithTdo:(DF::Tdo)tdo
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

    SCNGeometryElement* element = [[self class] createElement:object];

    SCNGeometry* obj = [SCNGeometry geometryWithSources:@[vertexSource, normalSource] elements:@[element]];
    
    auto quadIndicies = object.geometry.quads;

    SCNMaterial* material = [SCNMaterial material];
    material.doubleSided = YES;
    if (!geometry.quads.empty())
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
    }
    [obj insertMaterial:material atIndex:0];
    
    return obj;
}

- (NSArray*) createObjects
{
    NSMutableArray* objs = [NSMutableArray array];
    for (unsigned i = 0; i < _tdo.GetObjectsCount(); ++i)
        [objs addObject:[self createObject:i]];
    return objs;
}


@end
