#pragma once

#include <gober/TdoData.h>

namespace DF
{

/**
*/
struct TdoGeometry
{
    TdoVerticies verticies;
    TdoTriangles triangles;
    TdoQuads quads;
    TdoTextureVerticies textureVerticies;
    TdoTextureQuads textureQuads;
};

/**
*/
struct TdoObject
{
    tdo_texture_index texture;
    TdoGeometry geometry;
};

/**
*/
class Tdo
{
public:
    Tdo() { }

    Tdo(TdoTextures&& textures, std::vector<TdoObject>&& objects) :
        m_textures(std::move(textures)),
        m_objects(std::move(objects))
    { }
    
    /**
        Get the number of objects in the 3DO.
    */
    size_t GetObjectsCount() const { return m_objects.size(); }
    
    /**
        Access an object in the 3DO.
    */
    const TdoObject& GetObject(size_t index) { return m_objects[index]; }
    
private:
    TdoTextures m_textures;
    std::vector<TdoObject> m_objects;
};

} // DF