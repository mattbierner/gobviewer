#include "TdoFile.h"

#include <gober/Tdo.h>
#include "ObjParser.h"

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


namespace DF
{

/**
*/
using Texture = std::string;

using Textures = std::vector<Texture>;

using Vertex = boost::tuple<float, float, float>;

using Verticies = std::vector<Vertex>;

using Quad = boost::tuple<size_t, size_t, size_t, size_t, size_t, TdoShadingType>;

using Quads = std::vector<Quad>;

using TextureVertex = boost::tuple<float, float>;

using TextureVerticies = std::vector<TextureVertex>;

using TextureQuad = boost::tuple<size_t, size_t, size_t, size_t>;

using TextureQuads = std::vector<TextureQuad>;


using ObjectDefinition = boost::tuple<Verticies, Quads, TextureVerticies, TextureQuads>;

using Object = boost::tuple<int, ObjectDefinition>;

using Objects = std::vector<Object>;

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
            >> -quads;
        
        objects %= +object;
        
        // Verticies
        point %= base::value(float_);
        
        vertex %= base::attributeElement(int_, boost::proto::deep_copy(point >> point >> point));
        
        verticies %= base::list("VERTICES", boost::proto::deep_copy(vertex));
        
        // Quads
        index %= base::value(uint_);
        
        fill %= base::value(boost::proto::deep_copy(qi::attr_cast(base::identifier)));

        quad %= base::attributeElement(omit[int_], boost::proto::deep_copy(index >> index >> index >> index >> index >> fill));
        
        quads %= base::list("QUADS", boost::proto::deep_copy(quad));
        
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
    rule<Iterator, Object()> object;
    rule<Iterator, unsigned()> objectHeader;
    rule<Iterator, ObjectDefinition()> objectBody;

// Verticies
    rule<Iterator, Verticies()> verticies;
    rule<Iterator, Vertex()> vertex;
    
    rule<Iterator, float()> point;
    
// Quads
    rule<Iterator, Quads()> quads;
    rule<Iterator, Quad()> quad;
    
    rule<Iterator, unsigned()> index;
    rule<Iterator, TdoShadingType()> fill;
};

Tdo TdoFile::CreateTdo() const
{
    static const tdo_parser<const char*> p = { };

    const char* start = m_data.GetObjR<char>(0);
    const char* end = m_data.GetObjR<char>(m_data.GetDataSize() - 1);
    std::string data(start, m_data.GetDataSize() - 1);
    TdoFileData messages;
    bool result = parse(start, end, p, messages);
    
    auto x = boost::get<0>(messages);
    auto y = boost::get<1>(messages);
    if (!y.empty())
    {
        auto verts = boost::get<0>(boost::get<1>(y[0]));
        auto quads = boost::get<1>(boost::get<1>(y[0]));
        (void) quads;
    }
    std::cout << result << std::endl;
    return { };
}

} // DF