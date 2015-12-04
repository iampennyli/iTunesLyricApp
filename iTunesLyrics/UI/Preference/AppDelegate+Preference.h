//
//  AppDelegate+Preference.h
//  iTunesLyrics
//
//  Created by 鹏 李 on 10/18/15.
//  Copyright (c) 2015 Cocoamad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface AppDelegate(Preference)
- (IBAction)colorChanged:(id)sender;
- (IBAction)fontChanged:(id)sender;
- (IBAction)startupChanged:(id)sender;
- (void)preference:(NSNotification *)n;
- (void)hideLyricPanel:(NSNotification *)n;
@end
