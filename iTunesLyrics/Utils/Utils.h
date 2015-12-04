//
//  Utils.h
//  iTunesLyrics
//
//  Created by pennyli on 10/18/15.
//  Copyright (c) 2015 penny.li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "Marco.h"

@interface NSImage (CGImageRef)
- (CGImageRef)CGImage;
@end


CGPathRef createRoundRectPathInRect(CGRect rect, CGFloat radius);