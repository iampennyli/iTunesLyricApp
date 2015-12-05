//
//  iTunesLyricHelper.m
//  iTunesLyrics
//
//  Created by pennyli on 10/17/15.
//  Copyright (c) 2015 penny.li. All rights reserved.
//

#import "iTunesLyricHelper.h"
#import "ASIFormDataRequest.h"
#import "JSONKit.h"
#import "Marco.h"

@implementation iTunesLyricHelper

+ (instancetype)shareHelper;
{
    static iTunesLyricHelper *_helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_helper == nil) {
            _helper = [[iTunesLyricHelper alloc] init];
        }
    });
    
    return _helper;
}

- (instancetype)init
{
    if (self = [super init]) {
        _requestsDict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)smartFetchLyricWithSong:(Song *)song;
{
    if ([self readSongLyricFromLocal: song]) {
        [[NSNotificationCenter defaultCenter] postNotificationName: iTunesSongLyricFetchFinishedNotification object: song];
        return;
    }
    NSString *key = [NSString stringWithFormat: @"fetchLyricWithSong-%@-%ld", song.name, (long)song.duration];
    if ([_requestsDict objectForKey: key]) {
        return;
    }
    
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL: [NSURL URLWithString: FETCH_SONG_ID_URL]];
    [request addPostValue: song.name forKey: @"s"];
    [request addPostValue: @(1) forKey: @"type"];
    [request addPostValue: @"true" forKey: @"total"];
    [request addPostValue: @(100) forKey: @"limit"];
    [request addPostValue: @(0) forKey: @"offset"];
    [request addPostValue: @"<span class=\"s-fc2\">" forKey: @"hlpretag"];
    [request addPostValue: @"</span>" forKey: @"hlposttag"];
    [request addRequestHeader: @"Cookie" value: ENET_COOKIE];
    [request addRequestHeader: @"User-Agent" value: ENET_UA];
    request.timeOutSeconds = 5;
    
    [_requestsDict setValue: request forKey: key];
    
    __weak iTunesLyricHelper *helper = self;
    [request setCompletionBlock:^{
        
        id obj = request.responseString.objectFromJSONString;
        NSMutableArray *referenceSongs = [NSMutableArray array];
        NSArray *songsArray = obj[@"result"][@"songs"];
        for (NSDictionary *songDict in songsArray) {
            Song *song = [[Song alloc] init];
            song.name = songDict[@"name"];
            song.duration = (NSInteger)([songDict[@"duration"] integerValue] / 1000);
            song.album = songDict[@"album"][@"name"];
            song.lyricId = [songDict[@"id"] integerValue];
            song.score = [songDict[@"score"]integerValue];
            NSArray *artists = songDict[@"artists"];
            for (NSInteger i = 0; i < artists.count; i++) {
                NSString *artistName = artists[i][@"name"];
                if ([artistName length]) {
                    song.artist = artistName;
                    break;
                }
            }
            [referenceSongs addObject: song];
        }
        
        // 如果歌曲名字和歌曲时长都一致则认为是同一首歌
        for (Song *fetchSong in referenceSongs) {
            if (fetchSong.duration == song.duration && [fetchSong.name isEqualToString: song.name]) {
                song.lyricId = fetchSong.lyricId;
                NSString *timeStr = [NSString stringWithFormat:@"%.2ld:%.2ld",song.duration / 60, song.duration % 60];
                NSLog(@"%@-%@,找到正确的歌曲信息, 时间一致，id=%ld,duration=%@", song.name, song.artist,(long)song.lyricId, timeStr);
                break;
            }
        }
        
        if (song.lyricId) {
            [helper fetchLyricWithSong: song];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName: iTunesSongLyricFetchFinishedNotification object: song];
        }
        [helper.requestsDict removeObjectForKey: key];
    }];
    
    [request setFailedBlock:^{
        [helper.requestsDict removeObjectForKey: key];
    }];
    
    [request startAsynchronous];
}

- (void)fetchLyricListWithName:(NSString *)songName
{
    NSString *key = [NSString stringWithFormat: @"fetchLyricWithSong-%@", songName];
    if ([_requestsDict objectForKey: key]) {
        return;
    }
    
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL: [NSURL URLWithString: FETCH_SONG_ID_URL]];
    [request addPostValue: songName forKey: @"s"];
    [request addPostValue: @(1) forKey: @"type"];
    [request addPostValue: @"true" forKey: @"total"];
    [request addPostValue: @(100) forKey: @"limit"];
    [request addPostValue: @(0) forKey: @"offset"];
    [request addPostValue: @"<span class=\"s-fc2\">" forKey: @"hlpretag"];
    [request addPostValue: @"</span>" forKey: @"hlposttag"];
    [request addRequestHeader: @"Cookie" value: ENET_COOKIE];
    [request addRequestHeader: @"User-Agent" value: ENET_UA];
    request.timeOutSeconds = 5;
    
    [_requestsDict setValue: request forKey: key];
    
    __weak iTunesLyricHelper *helper = self;
    [request setCompletionBlock:^{
        
        id obj = request.responseString.objectFromJSONString;
        NSMutableArray *referenceSongs = [NSMutableArray array];
        NSArray *songsArray = obj[@"result"][@"songs"];
        for (NSDictionary *songDict in songsArray) {
            Song *song = [[Song alloc] init];
            song.name = songDict[@"name"];
            song.duration = (NSInteger)([songDict[@"duration"] integerValue] / 1000);
            song.album = songDict[@"album"][@"name"];
            song.lyricId = [songDict[@"id"] integerValue];
            song.score = [songDict[@"score"]integerValue];
            NSArray *artists = songDict[@"artists"];
            for (NSInteger i = 0; i < artists.count; i++) {
                NSString *artistName = artists[i][@"name"];
                if ([artistName length]) {
                    song.artist = artistName;
                    break;
                }
            }
            [referenceSongs addObject: song];
        }
        
        [referenceSongs sortUsingComparator:^NSComparisonResult(Song *song1, Song *song2) {
            return song1.score < song2.score;
        }];
        
        [[NSNotificationCenter defaultCenter] postNotificationName: iTunesLyricListFetchFinishedNotification object: referenceSongs];
        
    }];
    
    [request setFailedBlock:^{
         [[NSNotificationCenter defaultCenter] postNotificationName: iTunesLyricListFetchFinishedNotification object: nil];
        [helper.requestsDict removeObjectForKey: key];
    }];
    
    [request startAsynchronous];
}

- (void)fetchLyricWithSong:(Song *)song
{
    NSString *url = [NSString stringWithFormat: @"%@&id=%ld", FETCH_SONG_LYRIC_URL, song.lyricId];
    __weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL: [NSURL URLWithString: url]];
    [request addRequestHeader: @"Cookie" value: ENET_COOKIE];
    [request addRequestHeader: @"User-Agent" value: ENET_UA];
    NSString *key = [NSString stringWithFormat: @"_fetchLyricWithSong-%@-%ld", song.name, (long)song.duration];
    [self.requestsDict setValue: request forKey: key];
    __weak iTunesLyricHelper *helper = self;
    request.completionBlock = ^(void){
        [helper.requestsDict removeObjectForKey: key];
        id obj = request.responseString.objectFromJSONString;
        if ([obj[@"code"] integerValue] == 200) {
            NSString *lyric = obj[@"lrc"][@"lyric"];
            if (lyric.length) {
                song.lyrics = lyric;
                NSLog(@"%@-%@,找到正确的歌词信息", song.name, song.artist);
                [self saveSongLyricToLocal: song];
            } else {
                NSLog(@"%@-%@,没有找到正确的歌词信息", song.name, song.artist);
            }
        } else {
            NSLog(@"_fetchLyricWithSong err code %ld, reason: %@", [obj[@"code"] integerValue], obj);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName: iTunesSongLyricFetchFinishedNotification object: song];
    };
    [request setFailedBlock:^{
        NSLog(@"fetch lyric with id error");
        [[NSNotificationCenter defaultCenter] postNotificationName: iTunesSongLyricFetchFinishedNotification object: song];
        [helper.requestsDict removeObjectForKey: key];
    }];
    
    [request startAsynchronous];
}

- (void)saveSongLyricToLocal:(Song *)song
{
    NSString *lyricPath = [self lyricCachePath];
    NSString *fileName = [NSString stringWithFormat: @"%@-%@.li", song.name, @(song.duration)];
    lyricPath = [lyricPath stringByAppendingPathComponent: fileName];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue: @(song.lyricId) forKey: @"lyricId"];
    [dict setValue: song.lyrics forKey: @"lyrics"];
    
    [dict writeToFile: lyricPath  atomically: YES];
}

- (BOOL)readSongLyricFromLocal:(Song *)song
{
    NSString *lyricPath = [self lyricCachePath];
    NSString *fileName = [NSString stringWithFormat: @"%@-%@.li", song.name, @(song.duration)];
    lyricPath = [lyricPath stringByAppendingPathComponent: fileName];
    
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: lyricPath];
    if (dict) {
        song.lyricId = [dict[@"lyricId"] integerValue];
        song.lyrics = dict[@"lyrics"];
        return YES;
    }
    return NO;
}

- (NSString *)homePath
{
    NSString *userInfoPath = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
    userInfoPath = [userInfoPath stringByAppendingFormat:@"/iTunesLyrics/"];
    if ([[NSFileManager defaultManager] fileExistsAtPath: userInfoPath]) {
        return userInfoPath;
    } else {
        NSError *error = nil;
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath: userInfoPath withIntermediateDirectories: YES attributes: nil error: &error];
        if (!success) {
            NSLog(@"home path create error; %@", [error description]);
        }
        return nil;
    }
}

- (NSString *)lyricCachePath
{
    NSString *userHomePath = [self homePath];
    NSString *userCachePath = [userHomePath stringByAppendingPathComponent: @"lyrics"];
    if (![[NSFileManager defaultManager] fileExistsAtPath: userCachePath]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath: userCachePath withIntermediateDirectories: YES attributes: nil error: &error];
        if (error) {
            NSLog(@"cache folder create failed");
        }
        return userCachePath;
    }
    return userCachePath;
}

@end
