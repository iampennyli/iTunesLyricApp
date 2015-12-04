//
//  LyricDisplayWindow.h
//  iTunesLyrics
//
//  Created by 鹏 李 on 10/18/15.
//  Copyright (c) 2015 Cocoamad. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class InnerView;

@interface LyricDisplayWindow : NSPanel {
    InnerView *_innerView;
}

@property (nonatomic, strong) NSString *lyric;
@end

