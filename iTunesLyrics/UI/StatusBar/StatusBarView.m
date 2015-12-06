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
    
    newItem = [[NSMenuItem allocWithZone: [NSMenu menuZone]] initWithTitle: @"隐藏歌词" action: @selector(hideLyric:) keyEquivalent: @""];
    newItem.tag = kStatusShowLyricTag;

    [newItem setTarget: self];
    [newItem setEnabled: YES];
    [statusMenu addItem: newItem];
    
    newItem = [[NSMenuItem allocWithZone: [NSMenu menuZone]] initWithTitle: @"搜索歌词..." action: @selector(showPreference:) keyEquivalent: @""];
    newItem.tag = kStatusSearchLyricTag;
    
    [newItem setTarget: self];
    [newItem setEnabled: YES];
    [statusMenu addItem: newItem];
    
    [statusMenu addItem: [NSMenuItem separatorItem]];
    
    newItem = [[NSMenuItem allocWithZone: [NSMenu menuZone]] initWithTitle: @"偏好设置..." action: @selector(showPreference:) keyEquivalent: @""];
    newItem.tag = kStatusPreferenceTag;
    [newItem setTarget: self];
    [newItem setEnabled: YES];
    [statusMenu addItem: newItem];
    
    newItem = [[NSMenuItem allocWithZone: [NSMenu menuZone]] initWithTitle: @"检查更新..." action: @selector(showPreference:) keyEquivalent: @""];
    newItem.tag = kStatusCheckUpdateTag;
    [newItem setTarget: self];
    [newItem setEnabled: YES];
    [statusMenu addItem: newItem];
    
    [statusMenu addItem: [NSMenuItem separatorItem]];
    
    newItem = [[NSMenuItem allocWithZone: [NSMenu menuZone]] initWithTitle: @"反馈..." action: @selector(showPreference:) keyEquivalent: @""];
    [newItem setTarget: self];
    [newItem setEnabled: YES];
    newItem.tag = kStatusFeedbackTag;
    [statusMenu addItem: newItem];
    
    newItem = [[NSMenuItem allocWithZone: [NSMenu menuZone]] initWithTitle: @"关于..." action: @selector(showPreference:) keyEquivalent: @""];
    [newItem setTarget: self];
    [newItem setEnabled: YES];
    newItem.tag = kStatusAboutTag;
    [statusMenu addItem: newItem];
    
    [statusMenu addItem: [NSMenuItem separatorItem]];
    
    newItem = [[NSMenuItem allocWithZone: [NSMenu menuZone]] initWithTitle: @"Quit" action: @selector(quit) keyEquivalent: @""];
    [newItem setTarget: self];
    [newItem setEnabled: YES];
    newItem.tag = kStatusQuitTag;
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
    if ([item.title isEqualToString: @"隐藏歌词"]) { // show lyric
        item.title = @"显示歌词";
        needHide = YES;
    } else { // hide lyric
        item.title = @"隐藏歌词";
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