#import <Cocoa/Cocoa.h>

@class GobViewController;

@interface GobViewWindowController : NSWindowController<
    NSUserInterfaceValidations>

@property (nonatomic, strong) IBOutlet GobViewController* gobViewController;

- (void) loadGob:(NSURL*)path;

@end
