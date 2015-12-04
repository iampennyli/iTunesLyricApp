//
//  LyricDisplayWindow.h
//  iTunesLyrics
//
//  Created by pennyli on 10/18/15.
//  Copyright (c) 2015 penny.li. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class InnerView;

@interface LyricDisplayWindow : NSPanel {
    InnerView *_innerView;
}

@property (nonatomic, strong) NSString *lyric;
@end

