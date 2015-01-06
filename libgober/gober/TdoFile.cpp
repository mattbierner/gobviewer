#include "TdoFile.h"
#include <gober/Tdo.h>

#include <boost/fusion/include/boost_tuple.hpp>
#include <boost/spirit/home/qi.hpp>

using namespace boost::spirit::qi;

namespace DF
{

/**
*/
using message = boost::tuple<size_t, size_t, std::string>;

/**
*/
using message_list = std::vector<message>;

/**
    MSG file format parser.
*/
template <typename Iterator>
struct msg_parser : grammar<Iterator, message_list()>
{

    msg_parser() : msg_parser::base_type(start)
    {
        real_parser<float, strict_ureal_policies<float>> version_number;

        quoted_string %= lexeme['"' >> +(~char_('"')) >> '"'];
        
        version = "MSG" >> omit[+space] >> version_number >> eol;
        
        count = "MSGS" >> omit[+space] >> int_ >> eol;
       
        comment %= "#" >> *(char_ - eol) >> eol;
        
        comment_or_space = (comment | +space);
        
        message %= int_ >> omit[+space] >> int_ >> ':' >> omit[*space] >> +quoted_string;
        
        contents %= *comment_or_space >> *(message >> *comment_or_space);
        
        end %= lit("END") >> *space;
        
        start
            %= omit[version]
            >> omit[*comment_or_space]
            >> omit[count]
            >> contents
            >> omit[end];
    }
    
    rule<Iterator, message_list()> start;
    rule<Iterator, float()> version;
    rule<Iterator, size_t()> count;
    rule<Iterator, std::string()> quoted_string;
    rule<Iterator, message_list()> contents;
    rule<Iterator, message()> message;
    rule<Iterator> comment;
    rule<Iterator> comment_or_space;
    rule<Iterator> end;
};
    
Tdo TdoFile::CreateTdo() const
{
   return { };
}

} // DF