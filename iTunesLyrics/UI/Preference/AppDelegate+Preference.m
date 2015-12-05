//
//  AppDelegate+Preference.m
//  iTunesLyrics
//
//  Created by pennyli on 10/18/15.
//  Copyright (c) 2015 penny.li. All rights reserved.
//

#import "AppDelegate+Preference.h"
#import "Marco.h"
#import "StatusBarView.h"
#import "SearchLyricWindowController.h"

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
    switch ([[n object] integerValue]) {
        case kStatusPreferenceTag: {
            [NSApp activateIgnoringOtherApps:YES];
            [self.prefWindow makeKeyAndOrderFront: nil];
        }
            break;
        case kStatusSearchLyricTag: {
            [NSApp activateIgnoringOtherApps:YES];
            if (self.searchViewController == nil) {
                self.searchViewController = [[SearchLyricWindowController alloc] initWithWindowNibName: @"SearchLyricWindowController" Song: self.song];
                [self.searchViewController.window makeKeyAndOrderFront: nil];
            } else {
                self.searchViewController.song = self.song;
                [self.searchViewController.window makeKeyAndOrderFront: nil];
            }
        }
            break;
        case kStatusFeedbackTag: {
            
        }
            break;
        case kStatusAboutTag: {
            
        }
            break;
        default:
            break;
    }

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
