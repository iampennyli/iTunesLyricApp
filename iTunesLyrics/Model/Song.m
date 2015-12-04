//
//  Song.m
//  iTunesLyrics
//
//  Created by pennyli on 10/17/15.
//  Copyright (c) 2015 penny.li. All rights reserved.
//

#import "Song.h"

@implementation Song
- (instancetype)init
{
    if (self = [super init]) {
        _artist = @"default";
        _album = @"default";
        _lyricId = 0;
        _duration = 0;
    }
    return self;
}

- (BOOL)isEqual:(Song *)object
{
    return self.duration == object.duration && [self.name isEqualToString: object.name] && [self.artist isEqualToString: object.artist];
}
@end
