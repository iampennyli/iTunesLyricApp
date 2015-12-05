//
//  iTunesLyricHelper.h
//  iTunesLyrics
//
//  Created by pennyli on 10/17/15.
//  Copyright (c) 2015 penny.li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "Song.h"

typedef void (^FetchLyricListCompleteBlock)(NSArray *value);

@interface iTunesLyricHelper : NSObject

@property (nonatomic, strong)  NSMutableDictionary *requestsDict;

+ (instancetype)shareHelper;

/**
 根据iTunes歌曲信息智能获取歌词
 */
- (void)smartFetchLyricWithSong:(Song *)song;

/**
 根据歌曲名查询歌曲歌词列表
 */
- (void)fetchLyricListWithName:(NSString *)songName completeBlock:(FetchLyricListCompleteBlock)block;

/**
 根据歌曲（含有歌词id）获取歌词
 */
- (void)fetchLyricWithSong:(Song *)song;

/**
  保存歌词到本地
 */
- (void)saveSongLyricToLocal:(Song *)song;
@end
