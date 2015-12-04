//
//  LyricDisplayWindow.m
//  iTunesLyrics
//
//  Created by 鹏 李 on 10/18/15.
//  Copyright (c) 2015 Cocoamad. All rights reserved.
//

#import "LyricDisplayWindow.h"
#import "Utils.h"

@interface InnerView : NSView
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSColor *color;
@property (nonatomic, strong) NSFont *font;

@property (nonatomic, assign) BOOL mouseIn;

@property (nonatomic, strong) NSTrackingArea *trackingArea;
@end

@implementation InnerView

- (id)initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame: frameRect]) {
        
        [self updateTrackingAreas];

        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(colorChanged:) name: kNotificaiton_ColorChanged object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(fontChanged:) name: kNotification_FontChanged object: nil];
        
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey: @"lyricColor"];
        if (data) {
            self.color = (NSColor *)[NSUnarchiver unarchiveObjectWithData: data];
        }
        
        if (self.color == nil) {
            self.color = [NSColor redColor];
        }
        
        NSInteger fontSize = [[[NSUserDefaults standardUserDefaults] objectForKey: @"lyricFont"] integerValue];
        if (data) {
            self.font = [NSFont boldSystemFontOfSize: fontSize];
        }
        
        if (self.font == nil) {
            self.font = [NSFont boldSystemFontOfSize: 35];
        }
        
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

-(void)mouseEntered:(NSEvent *)theEvent
{
    self.mouseIn = YES;
    [self setNeedsDisplay: YES];
    [super mouseEntered: theEvent];
}

-(void)mouseExited:(NSEvent *)theEvent
{
    self.mouseIn = NO;
    [self setNeedsDisplay: YES];
    [super mouseExited: theEvent];
}

- (void)updateTrackingAreas
{
    if(self.trackingArea != nil) {
        [self removeTrackingArea: self.trackingArea];
    }
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    self.trackingArea = [ [NSTrackingArea alloc] initWithRect:[self bounds]
                                                 options:opts
                                                   owner:self
                                                userInfo:nil];
    [self addTrackingArea: self.trackingArea];
}

- (void)setText:(NSString *)text
{
    _text = text;
    [self setNeedsDisplay: YES];
}

- (void)colorChanged:(NSNotification *)n
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey: @"lyricColor"];
    if (data) {
        self.color = (NSColor *)[NSUnarchiver unarchiveObjectWithData: data];
        [self setNeedsDisplay: YES];
    }
}

- (void)fontChanged:(NSNotification *)n
{
    NSInteger fontSize = [[[NSUserDefaults standardUserDefaults] objectForKey: @"lyricFont"] integerValue];
    self.font = [NSFont boldSystemFontOfSize: fontSize];
    [self setNeedsDisplay: YES];
}

#define LeftMargin 50
#define TopMargin 10

- (void)drawRect:(NSRect)dirtyRect
{
    if (self.mouseIn) {
        
        CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
        
        CGPathRef path = createRoundRectPathInRect(self.bounds, 5);
        CGContextSaveGState(ctx);
        CGContextSetRGBFillColor(ctx, 0, 0, 0, .6);
        CGContextAddPath(ctx, path);
        CGContextFillPath(ctx);
        CGPathRelease(path);
        CGContextRestoreGState(ctx);
    }
    [_text drawInRect: NSMakeRect(LeftMargin, TopMargin, NSWidth(self.bounds) - 2 * LeftMargin, NSHeight(self.bounds) - 2 * TopMargin) withAttributes: @{NSFontAttributeName : self.font, NSForegroundColorAttributeName : self.color}];
}

@end

@implementation LyricDisplayWindow

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    if (self = [super initWithContentRect: contentRect styleMask: NSBorderlessWindowMask |NSNonactivatingPanelMask backing: NSBackingStoreBuffered defer: YES]) {
        _innerView = [[InnerView alloc] initWithFrame: contentRect];
        [self setContentView: _innerView];
        [self setLevel: NSStatusWindowLevel];
        [self setBackgroundColor: [NSColor clearColor]];
        
        [self setOpaque: NO];
        [self makeFirstResponder: _innerView];
        
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(fontChanged:) name: kNotification_FontChanged object: nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)setLyric:(NSString *)lyric;
{
    _lyric = lyric;
    NSRect frame = [self rectOfText: lyric font: _innerView.font];
    _innerView.frame = frame;
    [_innerView setText: lyric];
}

- (NSRect)rectOfText:(NSString *)text font:(NSFont *)font
{
    NSSize size = [text sizeWithAttributes: @{NSFontAttributeName : font}];
    size.width += 2 * LeftMargin;
    size.height += 2 * TopMargin;
    NSRect rect = NSMakeRect((NSWidth(self.frame) - size.width) * .5, (NSHeight(self.frame) - size.height) * .5, size.width, size.height);
    return rect;
}

- (void)fontChanged:(NSNotification *)n
{
    [self setLyric: _innerView.text];
}

#pragma mark MouseEvent
NSPoint mouseDownInitPoint;
- (void)mouseDown:(NSEvent *)theEvent
{
    NSRect windowFrame = [self frame];
    mouseDownInitPoint = [self convertBaseToScreen: [theEvent locationInWindow]];
    mouseDownInitPoint.x -= windowFrame.origin.x;
    mouseDownInitPoint.y -= windowFrame.origin.y;
    
    [super mouseDown: theEvent];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint currentPonit = [self convertBaseToScreen: [self mouseLocationOutsideOfEventStream]];
    NSPoint newPonit;
    newPonit.x = currentPonit.x - mouseDownInitPoint.x;
    newPonit.y = currentPonit.y - mouseDownInitPoint.y;
    [self setFrameOrigin: newPonit];
    
    [super mouseDragged: theEvent];
}
@end
