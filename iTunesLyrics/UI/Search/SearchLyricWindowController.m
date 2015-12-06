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

- (instancetype)initWithWindowNibName:(NSString *)windowNibName Song:(Song *)song
{
    if (self = [super initWithWindowNibName: windowNibName]) {
        // set preference window
        self.window.appearance = [NSAppearance appearanceNamed: NSAppearanceNameVibrantDark];
        _song = song;
    }
    return self;
}

- (void)setSong:(Song *)song
{
    if (![song.name isEqualToString: self.song.name]) {
        _song = song;
        _songs = nil;
        [self.tableView reloadData];
    }
    [self updateCurrentPlayingSongInfoUI];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    self.indicator = [[NSProgressIndicator alloc] initWithFrame: NSMakeRect(0, 0, 20, 20)];
    self.indicator.style = NSProgressIndicatorSpinningStyle;
    self.indicator.frame = CGRectMake((CGRectGetWidth(self.tableView.frame) - 20) * .5, (CGRectGetHeight(self.tableView.frame) - 20) * .5, 20, 20);
    self.indicator.autoresizingMask = NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin;
    [self.tableView addSubview: self.indicator];
    self.indicator.hidden = YES;
    
    [self updateCurrentPlayingSongInfoUI];
    
    [self.tableView setDoubleAction: @selector(importLyric:)];
    
}

- (void)updateCurrentPlayingSongInfoUI
{
    if (self.song.name.length) {
        self.searchField.stringValue = self.song.name;
        self.songNameLabel.stringValue = self.song.name;
    }
    if (self.song.artist.length) {
        self.singerNameLabel.stringValue = self.song.artist;
    }
    
    if (self.song.album.length) {
        self.albumLabel.stringValue = self.song.album;
    }
    
    self.durationLabel.stringValue = [NSString stringWithFormat:@"%.2ld:%.2ld",self.song.duration / 60,self.song.duration % 60];
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector;
{
    if ([@"insertNewline:" isEqualToString: NSStringFromSelector(commandSelector)]) {
        NSString *searchSongName = self.searchField.stringValue;
        if (searchSongName.length != 0) {
            
            [self lyricListFetchBegin];
            [[iTunesLyricHelper shareHelper] fetchLyricListWithName: searchSongName completeBlock:^(NSArray *songs) {
                [self lyricListFetchFinished: songs];
            }];
        }
    }
    return NO;
}

- (void)lyricListFetchBegin
{
    self.indicator.hidden = NO;
    [self.indicator startAnimation: nil];
}

- (void)lyricListFetchFinished:(NSArray *)songs
{
    [self.indicator stopAnimation: nil];
    self.indicator.hidden = YES;
    
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
        [[iTunesLyricHelper shareHelper] fetchLyricWithSong: song completeBlock:^(Song *final_song) {
            if (self.searchLyricDelegate && [self.searchLyricDelegate respondsToSelector: @selector(searchLyricDidImportLyricToSong:)]) {
                [self.searchLyricDelegate searchLyricDidImportLyricToSong: final_song];
            }
        }];
    }
}

@end
