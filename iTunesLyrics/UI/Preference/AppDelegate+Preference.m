//
//  AppDelegate+Preference.m
//  iTunesLyrics
//
//  Created by 鹏 李 on 10/18/15.
//  Copyright (c) 2015 Cocoamad. All rights reserved.
//

#import "AppDelegate+Preference.h"
#import "Marco.h"

@implementation AppDelegate(Preference)

- (IBAction)colorChanged:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName: kNotificaiton_ColorChanged object: nil];
}

- (IBAction)fontChanged:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName: kNotification_FontChanged object: nil];
}

- (IBAction)startupChanged:(id)sender
{
    
}

- (void)preference:(NSNotification *)n
{
    [NSApp activateIgnoringOtherApps:YES];
    [self.prefWindow makeKeyAndOrderFront: nil];
}

- (void)hideLyricPanel:(NSNotification *)n
{
    BOOL needHide = [[n object] boolValue];
    if (needHide) {
        [self.lyricWindow orderOut: nil];
    } else {
        NSString *lyric = self.lyricWindow.lyric;
        [self.lyricWindow setLyric: @""];
        [self.lyricWindow makeKeyAndOrderFront: nil];
        [self.lyricWindow setLyric: lyric];
    }
}
@end
