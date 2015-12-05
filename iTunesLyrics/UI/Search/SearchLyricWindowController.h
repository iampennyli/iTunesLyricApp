//
//  SearchLyricWindowController.h
//  iTunesLyrics
//
//  Created by 鹏 李 on 15/12/5.
//  Copyright © 2015年 Cocoamad. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Song.h"

@interface SearchLyricWindowController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate, NSSearchFieldDelegate> {
    NSArray *_songs;
}
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSSearchField *searchField;

@property (weak) IBOutlet NSTextField *songNameLabel;
@property (weak) IBOutlet NSTextField *singerNameLabel;
@property (weak) IBOutlet NSTextField *albumLabel;
@property (weak) IBOutlet NSTextField *durationLabel;

@property (strong) NSProgressIndicator *indicator;

@property (nonatomic, strong) Song *song;

- (instancetype)initWithWindowNibName:(NSString *)windowNibName Song:(Song *)song;

@end
