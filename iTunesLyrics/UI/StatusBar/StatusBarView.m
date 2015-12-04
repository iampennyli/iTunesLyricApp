//
//  StatusBarView.m
//  iTips
//
//  Created by Penny on 12-9-22.
//  Copyright (c) 2012年 Penny. All rights reserved.
//

#import "StatusBarView.h"
#import "Marco.h"

@interface StatusBarView()
-(void)initStatusMenu;
@end

@implementation StatusBarView

- (id)initWithFrame:(NSRect)frame
{
        // Initialization code here.
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength: -2];
    CGFloat itemWidth = [statusItem length];
    CGFloat itemHeight = [[NSStatusBar systemStatusBar] thickness];
    NSRect itemRect = NSMakeRect(0.0, 0.0, itemWidth, itemHeight);
    [statusItem setHighlightMode: YES];
    [self initStatusMenu];
    if (self = [super initWithFrame: itemRect]) {
        [statusItem setView: self];
        [statusItem setHighlightMode: YES]; 
        NSImage *normalImage = [NSImage imageNamed:@"star"];
        normalIcon = [normalImage CGImage];
    }
    
    return self;
}

- (void)dealloc
{
    CGImageRelease(normalIcon);
    [statusMenu removeAllItems];
    [[NSStatusBar systemStatusBar] removeStatusItem: statusItem];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [statusItem drawStatusBarBackgroundInRect: dirtyRect withHighlight: isHiLight];
    CGContextRef cxt = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    
    NSSize iconSize = NSMakeSize(18, 18);
    NSRect bound = [self bounds];
    CGFloat iconX = roundf((float)(NSWidth(bound) - iconSize.width) / 2);
    CGFloat iconY = roundf((float)(NSHeight(bound) - iconSize.height) / 2);
    NSRect rect = NSMakeRect(iconX, iconY, 18, 18);
    CGContextDrawImage(cxt, rect, normalIcon);
}

#pragma mark Private Method
- (void)initStatusMenu
{
    statusMenu = [[NSMenu allocWithZone: [NSMenu menuZone]] initWithTitle: @"menu"];
    statusMenu.delegate = self;
    NSMenuItem *newItem = nil;
    
    newItem = [[NSMenuItem allocWithZone: [NSMenu menuZone]] initWithTitle: @"Hide Lyric" action: @selector(hideLyric:) keyEquivalent: @""];
    newItem.tag = 0;

    [newItem setTarget: self];
    [newItem setEnabled: YES];
    [statusMenu addItem: newItem];
    
    newItem = [[NSMenuItem allocWithZone: [NSMenu menuZone]] initWithTitle: @"Preferences..." action: @selector(showPreference:) keyEquivalent: @""];
    newItem.tag = 1;
    [newItem setTarget: self];
    [newItem setEnabled: YES];
    [statusMenu addItem: newItem];
    
    [statusMenu addItem: [NSMenuItem separatorItem]];
    
    newItem = [[NSMenuItem allocWithZone: [NSMenu menuZone]] initWithTitle: @"Feedback..." action: @selector(showPreference:) keyEquivalent: @""];
    [newItem setTarget: self];
    [newItem setEnabled: YES];
    newItem.tag = 2;
    [statusMenu addItem: newItem];
    
    newItem = [[NSMenuItem allocWithZone: [NSMenu menuZone]] initWithTitle: @"About..." action: @selector(showPreference:) keyEquivalent: @""];
    [newItem setTarget: self];
    [newItem setEnabled: YES];
    newItem.tag = 3;
    [statusMenu addItem: newItem];
    
    [statusMenu addItem: [NSMenuItem separatorItem]];
    
    newItem = [[NSMenuItem allocWithZone: [NSMenu menuZone]] initWithTitle: @"Quit" action: @selector(quit) keyEquivalent: @""];
    [newItem setTarget: self];
    [newItem setEnabled: YES];
    [statusMenu addItem: newItem];
    
}
#pragma mark Mouse Event

- (void)rightMouseDown:(NSEvent *)theEvent
{
    isHiLight = YES;
    [self setNeedsDisplay: YES];
    [statusItem popUpStatusItemMenu: statusMenu];
    [super rightMouseDown: theEvent];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    isHiLight = YES;
    [self setNeedsDisplay: YES];
    [statusItem popUpStatusItemMenu: statusMenu];
    [super mouseDown: theEvent];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    isHiLight = NO;
    [self setNeedsDisplay: YES];
    [super mouseUp: theEvent];
}

#pragma mark NSMenu Delegate
- (void)menuWillOpen:(NSMenu *)menu 
{
    isHiLight = YES;
    [self setNeedsDisplay: YES];
}

- (void)menuDidClose:(NSMenu *)menu
{
    isHiLight = NO;
    [self setNeedsDisplay: YES];
}

#pragma mark NSMenu Action

- (void)hideLyric:(NSMenuItem *)item
{
    BOOL needHide = NO;
    if ([item.title isEqualToString: @"Hide Lyric"]) { // show lyric
        item.title = @"Show Lyric";
        needHide = YES;
    } else { // hide lyric
        item.title = @"Hide Lyric";
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kNotification_HideLyric object: @(needHide)];
}

- (void)showPreference:(NSMenuItem *)item
{
    [[NSNotificationCenter defaultCenter] postNotificationName: kNotification_ShowWindow object: @(item.tag)];
}

- (void)quit
{
    [[NSApplication sharedApplication] terminate: nil];
}

@end