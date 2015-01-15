#import <Foundation/Foundation.h>

#include <gob/GobFile.h>
#include <gob/Buffer.h>

/**
    Objective-c wrapper for a Gob file.
*/
@interface Gob : NSObject
{
    std::shared_ptr<Df::GobFile> _gob;
}

/**
    Load a gob from a file.
*/
+ (Gob*) createFromFile:(NSURL*)path;

/**
    Initilize with DF Gob.
*/
- (id) initWithGob:(std::shared_ptr<Df::GobFile>)gob;

/**
    Get the type of the file based on its extension.
*/
- (Df::FileType) getFileType:(NSString*)file;

/**
    Get the name of file at `index` in the Gob.
*/
- (NSString*) getFilename:(NSUInteger)index;

/**
    Get the number of files stored in the Gob.
*/
- (NSUInteger) getNumberOfFiles;

/**
    Read one of the files stored in the Gob.
*/
- (NSData*) readFile:(NSString*)file;

/**
    Read one of the files stored in the Gob and store the result in a buffer.
*/
- (Df::Buffer) readFileToBuffer:(NSString*)file;

@end
