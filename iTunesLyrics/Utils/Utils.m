//
//  Utils.m
//  iTunesLyrics
//
//  Created by pennyli on 10/18/15.
//  Copyright (c) 2015 penny.li. All rights reserved.
//

#import "Utils.h"

@implementation NSImage(CGImageRef)

- (CGImageRef)converte2CGImageRef
{
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)[self TIFFRepresentation], NULL);
    if (source) {
        CGImageRef maskRef =  CGImageSourceCreateImageAtIndex(source, 0, NULL);
        CFRelease(source);
        return maskRef;   // should release outside
    }
    return nil;
}

- (CGImageRef)CGImage
{
    return [self converte2CGImageRef];
}

@end

CGPathRef createRoundRectPathInRect(CGRect rect, CGFloat radius)
{
    CGFloat mr = MIN(CGRectGetHeight(rect), CGRectGetWidth(rect));
    
    CGFloat _radius = MIN(radius, 0.5f * mr);
    
    CGRect innerRect = CGRectInset(rect, _radius, _radius);
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, CGRectGetMinX(innerRect) - _radius, CGRectGetMinY(innerRect));
    
    CGPathAddArc(path, NULL, CGRectGetMinX(innerRect), CGRectGetMinY(innerRect), _radius, M_PI, 3 * M_PI_2, false);
    CGPathAddArc(path, NULL, CGRectGetMaxX(innerRect), CGRectGetMinY(innerRect), _radius, 3 * M_PI_2, 0, false);
    CGPathAddArc(path, NULL, CGRectGetMaxX(innerRect), CGRectGetMaxY(innerRect), _radius, 0, M_PI_2, false);
    CGPathAddArc(path, NULL, CGRectGetMinX(innerRect), CGRectGetMaxY(innerRect), _radius, M_PI_2, M_PI, false);
    CGPathCloseSubpath(path);
    
    return path;
}
