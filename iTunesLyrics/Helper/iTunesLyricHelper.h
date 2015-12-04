//
//  iTunesLyricHelper.h
//  iTunesLyrics
//
//  Created by 鹏 李 on 10/17/15.
//  Copyright (c) 2015 Cocoamad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "Song.h"

@interface iTunesLyricHelper : NSObject

@property (nonatomic, strong)  NSMutableDictionary *requestsDict;

+ (instancetype)shareHelper;

- (void)fetchLyricWithSong:(Song *)song;
@end
