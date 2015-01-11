#pragma once

#include <boost/fusion/include/boost_tuple.hpp>
#include <boost/spirit/home/qi.hpp>
#include <boost/spirit/include/lex_lexertl.hpp>

using namespace boost::spirit::qi;

namespace DF
{

/**
    Base grammar for file types that use the general Dark Forces syntax for
    defining objects and attributes.
*/
template <typename Iterator, typename ResultType>
struct ObjParser : grammar<Iterator, ResultType>
{
    /**
    */
    template<typename Name, typename Value>
    static auto attribute(Name name, Value value)
    {
        return boost::proto::deep_copy(name >> lit(':') >> omit[*space] >> value);
    }
    
    /**
    */
    template<typename Value>
    auto token(Value value)
    {
        return boost::proto::deep_copy(*comment_or_space >> value >> *comment_or_space);
    }
    
    /**
    */
    template<typename Name, typename Value>
    auto element(Name name, Value value)
    {
        return boost::proto::deep_copy(token(name >> omit[+space] >> value >> end_of_line));
    }
    
    /**
    */
    template<typename Name, typename Value>
    auto attributeElement(Name name, Value value)
    {
        return boost::proto::deep_copy(token(name >> lit(':') >> omit[*space] >> value >> end_of_line));
    }

    /**
    */
    template<typename Name, typename Item>
    auto list(Name name, Item item)
    {
        return boost::proto::deep_copy(
            omit[element(name, int_)] >> *item);
    }


    template <typename Start>
    ObjParser(Start&& start) : ObjParser::base_type(std::forward<Start>(start))
    {
        quoted_string %= lexeme['"' >> *(~char_('"')) >> '"'];
        
        comment = "#" >> *(char_ - eol) >> eol;
        
        comment_or_space = (comment | +space);
        
        end_of_line = *blank >> (comment | eol);
        
        identifier = +char_("_a-zA-Z0-9");
        
        filename = +char_("_:.\\a-zA-Z0-9");
    }
    
    rule<Iterator> comment;
    rule<Iterator> comment_or_space;
    rule<Iterator> end_of_line;
    
    rule<Iterator, std::string()> identifier;
    rule<Iterator, std::string()> filename;
    rule<Iterator, std::string()> quoted_string;

    real_parser<float, strict_ureal_policies<float>> version_number;
};

} // DF