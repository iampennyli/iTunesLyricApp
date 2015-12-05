//
//  SearchLyricWindowController.h
//  iTunesLyrics
//
//  Created by 鹏 李 on 15/12/5.
//  Copyright © 2015年 Cocoamad. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SearchLyricWindowController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate, NSSearchFieldDelegate> {
    NSArray *_songs;
}
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSSearchField *searchField;

@end
