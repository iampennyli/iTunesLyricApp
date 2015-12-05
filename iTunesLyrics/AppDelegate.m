//
//  AppDelegate.m
//  iTunesLyrics
//
//  Created by pennyli on 10/16/15.
//  Copyright (c) 2015 penny.li. All rights reserved.
//

#import "AppDelegate.h"
#import "ASIHTTPRequest.h"
#import "iTunes.h"
#import "iTunesLyricHelper.h"
#import "Marco.h"
#import "StatusBarView.h"
#import "AppDelegate+Preference.h"


@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (nonatomic, strong) StatusBarView *barView;
@property (nonatomic, strong) iTunesApplication *itunes;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSMutableDictionary *lyricDict;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    [self createLyricWindow];
    [self registerNotification];
    
    // init status bar icon
    self.barView = [[StatusBarView alloc] initWithFrame: NSMakeRect(0, 0, 24, 18)];
    
    // set preference window
    self.prefWindow.appearance = [NSAppearance appearanceNamed: NSAppearanceNameVibrantDark];
    
    // set itunes instance
    NSArray *apps = [[NSWorkspace sharedWorkspace] runningApplications];
    apps = [apps objectsAtIndexes:[apps indexesOfObjectsPassingTest:^BOOL(NSRunningApplication* obj, NSUInteger idx, BOOL *stop) {
        if ([obj.bundleIdentifier isEqualToString: @"com.apple.iTunes"]) {
            *stop = YES;
            return YES;
        }
        return NO;
    }]];
    
    if (apps.count == 1)
        self.itunes = [SBApplication applicationWithBundleIdentifier: @"com.apple.iTunes"];
    
    // init itunes playing state
    if ([self.itunes playerState] == iTunesEPlSPlaying) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval: .1 target: self selector: @selector(fetchProgress:) userInfo: nil repeats: YES];
        self.song = [self currentPlayingSong];
        if (self.song) {
            [self.lyricWindow setLyric: [NSString stringWithFormat: @"%@ - %@", self.song.name, self.song.artist]];
        } else
            [self.lyricWindow setLyric: @"没有检测到歌曲信息"];
        
        [[iTunesLyricHelper shareHelper] smartFetchLyricWithSong: self.song];
    }
}

- (void)createLyricWindow
{
    // create lyric window
    NSScreen *screen = [NSScreen mainScreen];
    self.lyricWindow = [[LyricDisplayWindow alloc] initWithContentRect: NSMakeRect(100, 100, CGRectGetWidth(screen.frame) - 2 * 100, 80) styleMask: NSBorderlessWindowMask backing: NSBackingStoreBuffered defer: NO];
    [self.lyricWindow setLyric: @""];
    [self.lyricWindow makeKeyAndOrderFront: nil];
}

- (void)registerNotification
{
    // set notificaiton
    NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
    [dnc addObserver:self selector:@selector(updateTrackInfo:) name: @"com.apple.iTunes.playerInfo" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(iTunesLyricFetchFinished:) name: iTunesSongLyricFetchFinishedNotification object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(preference:) name:kNotification_ShowWindow object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(hideLyricPanel:) name:kNotification_HideLyric object: nil];
}

#pragma mark - iTunes Song Playing
// get current playing song
- (Song *)currentPlayingSong
{
    NSString *songName = [[self.itunes currentTrack] name];
    if (songName.length == 0) {
        return nil;
    }
    
    Song *song = [[Song alloc] init];
    song.artist = [self.itunes currentTrack].artist;
    song.album = [self.itunes currentTrack].album;
    song.duration = [self.itunes currentTrack].duration;
    
    NSArray *songNames = [songName componentsSeparatedByString:@"("];
    if (songNames.count > 1) {
        song.name = songNames[0];
    } else
        song.name = songName;
    
    return song;
}

- (void)updateTrackInfo:(NSNotification *)n
{
    NSString *state = [n userInfo][@"Player State"];
    if ([state isEqualToString: @"Paused"]) {
        [self.timer invalidate];
        self.timer = nil;
    } else if ([state isEqualToString: @"Playing"]) {
        if (self.timer == nil) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval: .1 target: self selector: @selector(fetchProgress:) userInfo: nil repeats: YES];
        }
        
        if (![self.song isEqual: [self currentPlayingSong]]) {
            
            self.song = [self currentPlayingSong];
            if (self.song) {
                [self.lyricWindow setLyric: [NSString stringWithFormat: @"%@ - %@", self.song.name, self.song.artist]];
            } else
                [self.lyricWindow setLyric: @"没有检测到歌曲信息"];
            
            [[iTunesLyricHelper shareHelper] smartFetchLyricWithSong: self.song];
            
            if (![self.lyricWindow isVisible]) {
                [self.lyricWindow setLyric: @""];
                [self.lyricWindow makeKeyAndOrderFront: nil];
            }
        }
    }
}

// lyric fetch finished notficaiton
- (void)iTunesLyricFetchFinished:(NSNotification *)n
{
    Song *song = [n object];
    
    if (song.lyrics) {
        self.song.lyrics = song.lyrics;
        self.song.lyricId = song.lyricId;
        if (![song.name isEqualToString: self.song.name]) {
            [[iTunesLyricHelper shareHelper] saveSongLyricToLocal: self.song];
        }
    }
    
    if (song.lyrics) {
        [self analyzeLyric: song.lyrics];
    } else {
        [self.lyricDict removeAllObjects];
         [self.lyricWindow setLyric: @"没有检测到歌词信息"];
    }
}

// song playing timer call back
- (void)fetchProgress:(NSTimer *)timer
{
    double playerPosition = [self.itunes playerPosition];
    NSString *time = [self secs2String: playerPosition];
    NSString *lyricStr = self.lyricDict[time];
    if (lyricStr.length) {
        [self.lyricWindow setLyric: lyricStr];
    }
}

// util to convert sec to string
- (NSString *)secs2String:(NSInteger)time
{
    return [NSString stringWithFormat:@"%.2ld:%.2ld",time / 60,time % 60];
}

// analy lyric
- (void)analyzeLyric:(NSString *)lyrics
{
    if (self.lyricDict == nil) {
        self.lyricDict = [NSMutableDictionary dictionary];
    }
    [self.lyricDict removeAllObjects];
    
    NSArray *lyricsArray = [lyrics componentsSeparatedByString: @"\n"];
    for (NSString *lyric in lyricsArray) {
        if (lyric.length == 0) continue;
        NSArray *tmpArray = [lyric componentsSeparatedByString: @"]"];
        if ([tmpArray.firstObject length] < 1) continue;
        NSString *timeStr = [[tmpArray firstObject] substringFromIndex: 1];
        NSArray * timeArray = [timeStr componentsSeparatedByString:@"."];
        NSString * lyricTimeStr = timeArray.firstObject;
        NSString * lyricStr = tmpArray.lastObject;
        
        if (lyricTimeStr.length && lyricStr.length) {
            [self.lyricDict setValue: lyricStr forKey: lyricTimeStr];
        }
    }
}



- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
