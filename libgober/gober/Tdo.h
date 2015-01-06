#pragma once

#include <gober/TdoData.h>

namespace DF
{

/**
*/
struct TdoObject
{
    tdo_texture_index texture;
    
    std::vector<TdoVertex> verticies;
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

private:
    std::vector<std::string> textures;
    std::vector<TdoObject> objects;
};

} // DF