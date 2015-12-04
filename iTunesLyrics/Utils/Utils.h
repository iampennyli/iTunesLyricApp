//
//  Utils.h
//  iTunesLyrics
//
//  Created by 鹏 李 on 10/18/15.
//  Copyright (c) 2015 Cocoamad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "Marco.h"

@interface NSImage (CGImageRef)
- (CGImageRef)CGImage;
@end


CGPathRef createRoundRectPathInRect(CGRect rect, CGFloat radius);