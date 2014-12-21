//
//  AppDelegate.h
//  draw
//
//  Created by Matt Bierner on 12/18/14.
//  Copyright (c) 2014 Matt Bierner. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GobViewController;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, strong) IBOutlet GobViewController* gobViewController;

@end

