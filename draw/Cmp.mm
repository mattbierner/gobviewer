#import "Cmp.h"

#include "Gob.h"

#include <gob/Buffer.h>
#include <gob/GobFile.h>
#include <gob/CmpFile.h>

#include <iostream>

@implementation Cmp

+ (Cmp*) createFromGob:(NSString*)gobFile named:(NSString*)name;
{
    Gob* gob = [Gob createFromFile:[NSURL URLWithString:gobFile]];
    auto buffer = [gob readFileToBuffer:name];

    Df::CmpFile p(std::move(buffer));
    Df::CmpFileData data;
    p.Read(reinterpret_cast<uint8_t*>(&data), 0, sizeof(Df::CmpFileData));
    
    return [Cmp createForCmp:data];
}

+ (Cmp*) createForCmp:(Df::CmpFileData)p
{
    Cmp* cmp = [[Cmp alloc] init];
    cmp->_cmp = p;
    return cmp;
}

- (Df::CmpFileData) getData
{
    return _cmp;
}



@end
