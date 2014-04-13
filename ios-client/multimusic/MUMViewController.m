//
// Created by Mikkel Gravgaard on 15/03/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import "MUMViewController.h"
#import "MUMViewModel.h"
#import "UITableView+MUMAdditions.h"
#import "MUMTrackCell.h"
#import "LocalTrack.h"

@interface MUMViewController ()
@property (nonatomic, strong) MUMViewModel *viewModel;
@property (nonatomic, strong) id<MUMTrack> currentTrack;
@end

@implementation MUMViewController {

}

- (instancetype)init {
    if (!(self = [super init])) return nil;
    [self setup];
    return self;
}

- (void)setup {
    self.viewModel = [MUMViewModel new];
    RAC(self.viewModel,presentingViewController) = [[[self rac_signalForSelector:@selector(viewDidAppear:)]
            mapReplace:self]       //mapReplace -> distinct - will never change
            distinctUntilChanged];
}

- (void)updateOnClassInjection {
    @try{
        [self setup];
        [self loadView];
        [self viewDidAppear:YES];
    } @catch(NSException *e)  {
        NSLog(@"EXCEPTION ---- %@",e);
    }
}

- (void)loadView {
    [super loadView];
    UITableView *tableView = [UITableView new];
    [tableView registerClass:[MUMTrackCell class]];
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];

    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    RACSignal *tracks = [RACObserve(self.viewModel,tracks) ignore:nil];

    @weakify(tableView)
    [tracks subscribeNext:^(id x) {
        @strongify(tableView)
        [tableView reloadData];
    } error:^(NSError *error) {
        NSLog(@"%@",error);
    } completed:^{
        NSLog(@"completed");
    }];


}


#pragma tableview

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *tracks = self.viewModel.tracks;
    return tracks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id<MUMTrack> track = self.viewModel.tracks[(NSUInteger) indexPath.row];
    MUMTrackCell *cell = [tableView dequeueReusableCellWithClass:[MUMTrackCell class]];
    cell.textLabel.text = track.trackDescription;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id<MUMTrack> track = self.viewModel.tracks[(NSUInteger) indexPath.row];
    [self.currentTrack stop];
    self.currentTrack = track;
    [track play];
}

@end