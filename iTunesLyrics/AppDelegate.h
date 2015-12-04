//
//  AppDelegate.h
//  iTunesLyrics
//
//  Created by 鹏 李 on 10/16/15.
//  Copyright (c) 2015 Cocoamad. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LyricDisplayWindow.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, strong) LyricDisplayWindow *lyricWindow;
@property (nonatomic, weak) IBOutlet NSWindow *prefWindow;
@end

