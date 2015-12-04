//
//  AppDelegate.h
//  iTunesLyrics
//
//  Created by pennyli on 10/16/15.
//  Copyright (c) 2015 penny.li. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LyricDisplayWindow.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, strong) LyricDisplayWindow *lyricWindow;
@property (nonatomic, weak) IBOutlet NSWindow *prefWindow;
@end

