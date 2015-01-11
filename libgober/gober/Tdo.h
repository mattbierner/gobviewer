#pragma once

#include <gober/TdoData.h>

namespace DF
{

/**
*/
struct TdoObject
{
    tdo_texture_index texture;
    
    TdoVerticies verticies;
    std::vector<TdoTextureVertex> textureVerticies;

    std::vector<TdoTriangle> triangles;
    std::vector<TdoQuad> quads;
    std::vector<TdoTextureQuad> textureQuads;
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
    
private:
    TdoTextures m_textures;
    std::vector<TdoObject> m_objects;
};

} // DF