#include "MsgFile.h"
#include <gober/Msg.h>

#include <boost/fusion/include/boost_tuple.hpp>
#include <boost/spirit/home/qi.hpp>
#include <boost/spirit/include/lex_lexertl.hpp>

namespace lex = boost::spirit::lex;

using namespace boost::spirit::qi;

namespace DF
{

/**
*/
using message = boost::tuple<message_index_t, message_priority_t, message_contents_t>;

/**
*/
using message_list = std::vector<message>;


/**
    MSG file format parser.
*/
template <typename Iterator>
struct msg_parser : grammar<Iterator, message_list()>
{
    template<typename Name, typename Value>
    static auto element(Name name, Value value)
    {
        return name >> omit[+space] >> value;
    }
    
    template<typename Name, typename Attribute>
    static auto attributedElement(Name name, Attribute attr)
    {
        return name >> omit[+space] >> attr;
    }
    
    template<typename Name, typename Value>
    static auto attribute(Name name, Value&& value)
    {
        return name >> ':' >> omit[*space] >> value;
    }

    msg_parser() : msg_parser::base_type(start)
    {
        real_parser<float, strict_ureal_policies<float>> version_number;

        quoted_string %= lexeme['"' >> +(~char_('"')) >> '"'];
        
        version = element("MSG", version_number) >> eol;
        
        count = element("MSGS", int_) >> eol;
       
        comment %= "#" >> *(char_ - eol) >> eol;
        
        comment_or_space = (comment | +space);
        
        message %= int_ >> omit[+space] >> attribute(int_, +quoted_string);
        
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
    
Msg MsgFile::CreateMsg() const
{
    static const msg_parser<const char*> p = { };

    const char* start = m_data.GetObjR<char>(0);
    const char* end = m_data.GetObjR<char>(m_data.GetDataSize() - 1);
    
    message_list messages;
    bool result = parse(start, end, p, messages);
    
    Msg messageObject = { };
    if (result && (start == end)) // only accept fully valid files
    {
        for (const auto& message : messages)
            messageObject.AddMessage(
                boost::get<0>(message),
                boost::get<1>(message),
                std::move(boost::get<2>(message)));
    }
    
    {
        static const msg_parser<std::string::const_iterator> p = { };
        const std::string s = "0 1:\"x\"";
        
        message messages;
        bool result = parse(std::begin(s), std::end(s), p.message, messages);
        result;
    }
    
    return messageObject;
}

} // DF