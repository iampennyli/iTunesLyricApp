//
//  StatusBarView.h
//  iTips
//
//  Created by Penny on 12-9-22.
//  Copyright (c) 2012年 Penny. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Utils.h"
@interface StatusBarView : NSView <NSMenuDelegate, NSWindowDelegate> {
    NSStatusItem    *statusItem;
    NSMenu          *statusMenu;
    CGImageRef      normalIcon;
    BOOL            isHiLight;
}

@end

