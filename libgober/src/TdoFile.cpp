#include "TdoFile.h"

#include <gober/Tdo.h>
#include "ObjParser.h"

#include <boost/fusion/adapted/struct/adapt_struct.hpp>
#include <boost/fusion/include/adapt_struct.hpp>
#include <boost/fusion/include/boost_tuple.hpp>
#include <boost/spirit/home/qi.hpp>
#include <boost/phoenix.hpp>

using namespace boost::spirit;
using namespace boost::spirit::qi;
namespace ph = boost::phoenix;


namespace boost { namespace spirit { namespace traits
{

/**
    Convert strings to shading types.
*/
template <>
struct transform_attribute<DF::TdoShadingType, std::string, qi::domain>
{
    using type = std::string;
    
    static std::string pre(DF::TdoShadingType& d) { return ""; }
    
    static void post(DF::TdoShadingType& val, const std::string& attr)
    {
        auto found = DF::shadingNameMap.find(attr);
        if (found != std::end(DF::shadingNameMap))
            val = found->second;
        else
            val = DF::TdoShadingType::Unknown;
    }
    
    static void fail(DF::TdoShadingType&) { /*noop*/ }
};

}}} // boost::sprint::trains

BOOST_FUSION_ADAPT_STRUCT(
    DF::TdoVertex,
    (DF::tdo_coordinate, x)
    (DF::tdo_coordinate, y)
    (DF::tdo_coordinate, z));

BOOST_FUSION_ADAPT_STRUCT(
    DF::TdoTextureVertex,
    (DF::tdo_texture_coordinate, x)
    (DF::tdo_texture_coordinate, y));

BOOST_FUSION_ADAPT_STRUCT(
    DF::TdoTriangle,
    (DF::tdo_vertex_index, a)
    (DF::tdo_vertex_index, b)
    (DF::tdo_vertex_index, c)
    (DF::tdo_color_index, color)
    (DF::TdoShadingType, fill));

BOOST_FUSION_ADAPT_STRUCT(
    DF::TdoQuad,
    (DF::tdo_vertex_index, a)
    (DF::tdo_vertex_index, b)
    (DF::tdo_vertex_index, c)
    (DF::tdo_vertex_index, d)
    (DF::tdo_color_index, color)
    (DF::TdoShadingType, fill));

BOOST_FUSION_ADAPT_STRUCT(
    DF::TdoTextureQuad,
    (DF::tdo_texture_vertex_index, a)
    (DF::tdo_texture_vertex_index, b)
    (DF::tdo_texture_vertex_index, c)
    (DF::tdo_texture_vertex_index, d));

BOOST_FUSION_ADAPT_STRUCT(
    DF::TdoTextureTriangle,
    (DF::tdo_texture_vertex_index, a)
    (DF::tdo_texture_vertex_index, b)
    (DF::tdo_texture_vertex_index, c));

BOOST_FUSION_ADAPT_STRUCT(
    DF::TdoGeometry,
    (DF::TdoVerticies, verticies)
    (DF::TdoTriangles, triangles)
    (DF::TdoQuads, quads)
    (DF::TdoTextureVerticies, textureVerticies)
    (DF::TdoTextureQuads, textureQuads)
    (DF::TdoTextureTriangles, textureTriangles));

BOOST_FUSION_ADAPT_STRUCT(
    DF::TdoObject,
    (DF::tdo_texture_index, texture)
    (DF::TdoGeometry, geometry));

namespace DF
{

using Texture = std::string;

using Textures = std::vector<Texture>;

using Objects = std::vector<TdoObject>;

using TdoFileData = boost::tuple<Textures, Objects>;

/**
    MSG file format parser.
*/
template <typename Iterator>
struct tdo_parser : ObjParser<Iterator, TdoFileData()>
{
    using base = ObjParser<Iterator, TdoFileData()>;

    tdo_parser() : base(start)
    {
        version = base::element("3DO", base::version_number);
        
        name = base::element("3DONAME", omit[base::identifier]);

        objectsCount = base::element("OBJECTS", int_);

        verticiesCount = base::element("VERTICES", int_);
        
        polygonsCount = base::element("POLYGONS", int_);

        palette = base::element("PALETTE", boost::proto::deep_copy(base::filename));

        header
            %= version
            >> name
            >> objectsCount
            >> verticiesCount
            >> polygonsCount
            >> palette;
        
        texture %= base::attributeElement("TEXTURE", boost::proto::deep_copy(base::filename));

        textures %= base::list("TEXTURES", boost::proto::deep_copy(texture));

        // Object
        object
            %= objectHeader
            >> objectBody;
        
        objectHeader
            %= omit[base::element("OBJECT", boost::proto::deep_copy(base::quoted_string))]
            >> base::element("TEXTURE", int_);
        
        objectBody
            %= verticies
            >> -triangles
            >> -quads
            >> -textureVerticies
            >> -textureQuads
            >> -textureTriangles;
        
        objects %= +object;
        
        // Verticies
        point %= base::value(float_);
        
        vertex %=
            base::attributeElement(omit[int_],
                boost::proto::deep_copy(point >> point >> point));
        
        verticies %= base::list("VERTICES", boost::proto::deep_copy(vertex));
        
      
        index %= base::value(uint_);
        
        fill %= base::value(boost::proto::deep_copy(qi::attr_cast(base::identifier)));
        
        // Triangles
        triangle %=
            base::attributeElement(omit[int_],
                boost::proto::deep_copy(index >> index >> index >> index >> fill));
        
        triangles %= base::list("TRIANGLES", boost::proto::deep_copy(triangle));

        // Quads
        quad %=
            base::attributeElement(omit[int_],
                boost::proto::deep_copy(index >> index >> index >> index >> index >> fill));
        
        quads %= base::list("QUADS", boost::proto::deep_copy(quad));
        
        // Texture Verticies
        textureVertex %= base::attributeElement(omit[int_], boost::proto::deep_copy(point >> point));
        
        textureVerticies %=
            base::list("TEXTURE VERTICES",
                boost::proto::deep_copy(textureVertex));
        
        // Texture Quads
        textureQuad %=
            base::attributeElement(omit[int_],
                boost::proto::deep_copy(index >> index >> index >> index));
        
        textureQuads %=
            base::list("TEXTURE QUADS",
                boost::proto::deep_copy(textureQuad));
        
        // Texture Triangles
        textureTriangle %=
            base::attributeElement(omit[int_],
                boost::proto::deep_copy(index >> index >> index));
        
        textureTriangles %=
            base::list("TEXTURE TRIANGLES",
                boost::proto::deep_copy(textureTriangle));
        
        //
        start
            %= omit[header]
            >> textures
            >> objects;
    }
    
    rule<Iterator, TdoFileData()> start;
    rule<Iterator, TdoFileData()> contents;
    
    
// Header
    rule<Iterator> header;
    rule<Iterator> version;
    rule<Iterator> name;
    rule<Iterator> objectsCount;
    rule<Iterator> verticiesCount;
    rule<Iterator> polygonsCount;
    rule<Iterator> palette;

// Textures
    rule<Iterator, Textures()> textures;
    rule<Iterator, Texture()> texture;

// Object
    rule<Iterator, Objects()> objects;
    rule<Iterator, TdoObject()> object;
    rule<Iterator, unsigned()> objectHeader;
    rule<Iterator, TdoGeometry()> objectBody;

// Verticies
    rule<Iterator, TdoVerticies()> verticies;
    rule<Iterator, TdoVertex()> vertex;
    
    rule<Iterator, float()> point;
    rule<Iterator, unsigned()> index;
    rule<Iterator, TdoShadingType()> fill;
    
// Triangle
    rule<Iterator, TdoTriangles()> triangles;
    rule<Iterator, TdoTriangle()> triangle;
    
// Quads
    rule<Iterator, TdoQuads()> quads;
    rule<Iterator, TdoQuad()> quad;

// Texture Verticies
    rule<Iterator, TdoTextureVerticies()> textureVerticies;
    rule<Iterator, TdoTextureVertex()> textureVertex;
    
// Texture Quads
    rule<Iterator, TdoTextureQuads()> textureQuads;
    rule<Iterator, TdoTextureQuad()> textureQuad;

// Texture Triangles
    rule<Iterator, TdoTextureTriangles()> textureTriangles;
    rule<Iterator, TdoTextureTriangle()> textureTriangle;
};

Tdo TdoFile::CreateTdo() const
{
    static const tdo_parser<const char*> p = { };

    const char* start = m_data.GetObjR<char>(0);
    const char* end = m_data.GetObjR<char>(m_data.GetDataSize() - 1);
    std::string data(start, m_data.GetDataSize() - 1);
    TdoFileData messages;
    bool result = parse(start, end, p, messages);
    
    std::cout << result << std::endl;
    return Tdo(
        std::move(boost::get<0>(messages)),
        std::move(boost::get<1>(messages)));
}

} // DF