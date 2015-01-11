#include "TdoFile.h"

#include <gober/Tdo.h>
#include "ObjParser.h"

#include <boost/fusion/include/boost_tuple.hpp>
#include <boost/spirit/home/qi.hpp>

using namespace boost::spirit::qi;

namespace DF
{

/**
*/
using Texture = std::string;

using Textures = std::vector<Texture>;

using Vertex = boost::tuple<float, float, float>;

using Verticies = std::vector<Vertex>;

using Quad = boost::tuple<size_t, size_t, size_t, size_t, size_t, std::string>;

using Quads = std::vector<Quad>;

using TextureVertex = boost::tuple<float, float>;

using TextureVerticies = std::vector<TextureVertex>;

using TextureQuad = boost::tuple<size_t, size_t, size_t, size_t>;

using TextureQuads = std::vector<TextureQuad>;

/**
*/
using Object = boost::tuple<std::size_t, unsigned, Verticies, Quads, TextureVerticies, TextureQuads>;

/**
*/
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
        
        name = base::element("3DONAME", omit[+base::identifier]);

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

        start
            %= omit[header]
            >> textures;
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

// Verticies
    rule<Iterator, Verticies()> verticies;
    rule<Iterator, Vertex()> vertex;
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
    std::cout << result << std::endl;
    return { };
}

} // DF