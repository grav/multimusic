//
// Created by Mikkel Gravgaard on 15/03/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import "MUMViewController.h"
#import "MUMViewModel.h"
#import "UITableView+MUMAdditions.h"
#import "MUMTrackCell.h"
#import "Track.h"
#import "Masonry.h"
#import <AVFoundation/AVFoundation.h>
#import "ReactiveCocoa.h"
#import "MUMConstants.h"

@interface MUMViewController ()
@property (nonatomic, strong) MUMViewModel *viewModel;
@property (nonatomic, strong) AVPlayer *player;
@end

@implementation MUMViewController {

}

- (instancetype)init {
    if (!(self = [super init])) return nil;
    self.viewModel = [MUMViewModel new];
    return self;
}

- (void)loadView {
    [super loadView];
    UITableView *tableView = [UITableView new];
    [tableView registerClassAndReuseIdentifier:[MUMTrackCell class]];
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];

    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    RACSignal *dataSignal = RACObserve(self.viewModel,tracks);
    [tableView rac_liftSelector:@selector(reloadWithBang:) withSignalsFromArray:@[dataSignal]];

}


#pragma tableview

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *tracks = self.viewModel.tracks;
    return tracks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Track *track = self.viewModel.tracks[(NSUInteger) indexPath.row];
    MUMTrackCell *cell = [tableView dequeueReusableCellWithClass:[MUMTrackCell class]];
    cell.textLabel.text = [track asString];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Track *track = self.viewModel.tracks[(NSUInteger) indexPath.row];
    [self play:track];
}

- (void)play:(Track*)track
{
    self.player = [[AVPlayer alloc] initWithURL:[track playbackUrl]];
    [self.player play];
}

@end