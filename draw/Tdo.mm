#import "Tdo.h"

#import <SceneKit/SceneKit.h>

#import "Pal.h"

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

+ (SCNGeometryElement*) createElement:(const DF::TdoObject&)obj;
+ (SCNGeometryElement*) createElementForQuads:(const DF::TdoObject&)obj;
+ (SCNGeometryElement*) createElementForTriangles:(const DF::TdoObject&)obj;

@end


@implementation Tdo

+ (SCNGeometrySource*) createVertexSource:(const DF::TdoObject&)obj
{
    auto verts = obj.geometry.verticies;
    size_t size = verts.size();
    
    std::vector<SCNVector3> data(size);
    for (unsigned i = 0; i < size; ++i)
        data[i] = dfToScn(verts[i]);
    
    SCNGeometrySource* source = [SCNGeometrySource geometrySourceWithVertices:&data[0] count:size];
    return source;
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
    auto verts = obj.geometry.verticies;
    size_t size = verts.size();
    
    auto quadIndicies = obj.geometry.quads;
    size_t numQuads = quadIndicies.size();
    
    std::vector<SCNVector3> data(size);
    for (unsigned i = 0; i < numQuads; ++i)
    {
        auto quad = quadIndicies[i];
        
        auto a = dfToScn(verts[quad.a]);
        auto b = dfToScn(verts[quad.b]);
        auto c = dfToScn(verts[quad.c]);

        auto norm1 = getNormal(c, b, a);
        data[quad.a] = data[quad.b] = data[quad.c] = data[quad.d] = norm1;
    }
    SCNGeometrySource* source = [SCNGeometrySource geometrySourceWithNormals:&data[0] count:size];
    return source;
}

+ (SCNGeometrySource*) createNormalsForTriangles:(const DF::TdoObject&)obj
{
    auto verts = obj.geometry.verticies;
    size_t size = verts.size();
    
    auto indicies = obj.geometry.triangles;
    size_t numTriangles = indicies.size();
    
    std::vector<SCNVector3> data(size);
    for (unsigned i = 0; i < numTriangles; ++i)
    {
        auto triangle = indicies[i];
        
        auto a = dfToScn(verts[triangle.a]);
        auto b = dfToScn(verts[triangle.b]);
        auto c = dfToScn(verts[triangle.c]);

        auto norm1 = getNormal(a, b, c);
        data[triangle.a] = data[triangle.b] = data[triangle.c] = norm1;
    }
    SCNGeometrySource* source = [SCNGeometrySource geometrySourceWithNormals:&data[0] count:size];
    return source;
}

+ (SCNGeometryElement*) createElement:(const DF::TdoObject&)obj
{
    if (!obj.geometry.quads.empty())
        return [Tdo createElementForQuads: obj];
    else
        return [Tdo createElementForTriangles: obj];
}

+ (SCNGeometryElement*) createElementForQuads:(const DF::TdoObject&)obj
{
    auto quadIndicies = obj.geometry.quads;
    size_t size = quadIndicies.size();
    
    std::vector<unsigned> indices;
    indices.reserve(size * 6);
    for (unsigned i = 0; i < size; ++i)
    {
        auto quad = quadIndicies[i];
        indices.push_back(quad.c);
        indices.push_back(quad.b);
        indices.push_back(quad.a);
        
        indices.push_back(quad.a);
        indices.push_back(quad.d);
        indices.push_back(quad.c);
    }

    NSData *indexData = [NSData dataWithBytes:&indices[0] length:indices.size() * sizeof(unsigned)];

    return [SCNGeometryElement geometryElementWithData:indexData
                                    primitiveType:SCNGeometryPrimitiveTypeTriangles
                                     primitiveCount:size * 2
                                      bytesPerIndex:sizeof(unsigned)];
}

+ (SCNGeometryElement*) createElementForTriangles:(const DF::TdoObject&)obj
{
    auto triangleIndicies = obj.geometry.triangles;
    size_t size = triangleIndicies.size();
    
    std::vector<unsigned> indices;
    indices.reserve(size * 3);
    for (unsigned i = 0; i < size; ++i)
    {
        auto triangle = triangleIndicies[i];
        indices.push_back(triangle.a);
        indices.push_back(triangle.b);
        indices.push_back(triangle.c);
    }

    NSData *indexData = [NSData dataWithBytes:&indices[0] length:indices.size() * sizeof(unsigned)];

    return [SCNGeometryElement geometryElementWithData:indexData
                                    primitiveType:SCNGeometryPrimitiveTypeTriangles
                                     primitiveCount:size
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
    auto object = _tdo.GetObject(index);
    auto quads = object.geometry.quads;
    
    SCNGeometrySource* vertexSource = [[self class] createVertexSource:object];
    SCNGeometrySource* normalSource = [[self class] createNormalsSource:object];

    SCNGeometryElement* element = [[self class] createElement:object];

    SCNGeometry* obj = [SCNGeometry geometryWithSources:@[vertexSource, normalSource] elements:@[element]];
    
    auto quadIndicies = object.geometry.quads;

    SCNMaterial* material = [SCNMaterial material];
    material.doubleSided = YES;
    if (!quads.empty())
    {
        auto quad = quads[0];
        auto color = [self.pal getColor:quad.color];
        material.diffuse.contents = [NSColor whiteColor];//color;
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
