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

@interface iTunesLyricHelper : NSObject

@property (nonatomic, strong)  NSMutableDictionary *requestsDict;

+ (instancetype)shareHelper;

- (void)fetchLyricWithSong:(Song *)song;
@end
