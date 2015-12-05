//
//  SearchLyricWindowController.m
//  iTunesLyrics
//
//  Created by 鹏 李 on 15/12/5.
//  Copyright © 2015年 Cocoamad. All rights reserved.
//

#import "SearchLyricWindowController.h"
#import "iTunesLyricHelper.h"
#import "Marco.h"

@interface SearchLyricWindowController ()

@end

@implementation SearchLyricWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(lyricListFetchFinished:) name: iTunesLyricListFetchFinishedNotification object: nil];
    
    [self.tableView setDoubleAction: @selector(importLyric:)];
    
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector;
{
    if ([@"insertNewline:" isEqualToString: NSStringFromSelector(commandSelector)]) {
        NSString *searchSongName = self.searchField.stringValue;
        if (searchSongName.length != 0) {
            [[iTunesLyricHelper shareHelper] fetchLyricListWithName: searchSongName];
        }
    }
    return NO;
}

- (void)lyricListFetchFinished:(NSNotification *)n
{
    NSArray *songs = [n object];
    if (songs.count) {
        _songs = songs;
        [self.tableView reloadData];
    } else
        _songs = [NSArray array];
}

#pragma mark - TableView
- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row NS_AVAILABLE_MAC(10_7)
{
    Song *song = _songs[row];
    
    NSTableCellView *view = [tableView makeViewWithIdentifier: tableColumn.identifier owner: self];
    NSString *identifier = tableColumn.identifier;
    NSString *value = @"";
    if ([identifier isEqualToString: @"name"]) {
        value = song.name;
    } else if ([identifier isEqualToString: @"singer"]) {
        value = song.artist;
    } else if ([identifier isEqualToString: @"album"]) {
        value = song.album;
    } else if ([identifier isEqualToString: @"duration"]) {
        value = [NSString stringWithFormat:@"%.2ld:%.2ld",song.duration / 60,song.duration % 60];;
    } else if ([identifier isEqualToString: @"hot"]) {
        value = [NSString stringWithFormat: @"%ld", song.score];
    }
    view.textField.stringValue = value;
    
    return view;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 20;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return _songs.count;
}

#pragma mark -
- (void)importLyric:(NSTableView *)tableView
{
    NSInteger index = [tableView selectedRow];
    if (index != NSNotFound && index < _songs.count) {
        Song *song = _songs[index];
        [[iTunesLyricHelper shareHelper] fetchLyricWithSong: song];
    }
}

@end
