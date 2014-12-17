//
// Created by Mikkel Gravgaard on 15/03/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import <NSArray+Functional/NSArray+Functional.h>
#import "MUMTableViewController.h"
#import "MUMViewModel.h"
#import "UITableView+MUMAdditions.h"
#import "MUMTrackCell.h"
#import "HTTPStreamingTrack.h"
#import "MUMSpotifyClient.h"
#import "MUMSoundCloudClient.h"
#import "MUMHTTPStreamingClient.h"
#import "NSArray+MUMAdditions.h"
#import <MediaPlayer/MediaPlayer.h>

typedef NSInteger(^NextFn)(NSInteger);

@interface MUMTableViewController () <UISearchBarDelegate, UISearchDisplayDelegate>
@property (nonatomic, strong) MUMViewModel *tracksViewModel;
@property (nonatomic, strong) id<MUMTrack> currentTrack;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (strong, nonatomic) UISearchDisplayController *searchController;
@property (nonatomic, strong) NSArray *clientsWantingViewController;
@end

@implementation MUMTableViewController {

}

int mod(int a, int b)
{
    return ((a % b) + b) % b;
}

- (instancetype)initWithViewModel:(MUMViewModel *)viewModel {
    if (!(self = [super init])) return nil;
    self.tracksViewModel = viewModel;
    [self setup];

    [RACObserve(self.tracksViewModel, playing) subscribeNext:^(id x) {
        NSLog(@"playing: %@",x);
    }];

    RACSignal *remoteControlSignal = [[self rac_signalForSelector:@selector(remoteControlReceivedWithEvent:)] map:^id(RACTuple *tuple) {
        return tuple.first;
    }];

    RACSignal *prevS = [[remoteControlSignal filter:^BOOL(UIEvent *event) {
        return event.subtype == UIEventSubtypeRemoteControlPreviousTrack;

    }] mapReplace:^NSInteger(NSInteger a) {
        return a - 1;
    }];

    RACSignal *nextS = [[remoteControlSignal filter:^BOOL(UIEvent *event) {
        return event.subtype == UIEventSubtypeRemoteControlNextTrack;
    }] mapReplace:^NSInteger(NSInteger a) {
        return a + 1;
    }];

    RACSignal *absoluteS = [[self rac_signalForSelector:@selector(tableView:didSelectRowAtIndexPath:)
                    fromProtocol:@protocol(UITableViewDelegate)] map:^id(RACTuple *tuple) {
        NSIndexPath *indexPath = tuple.second;
        return ^NSInteger (NSInteger _){return indexPath.row;};
    }];

    RACSignal *tracksSignal = RACObserve(self.tracksViewModel, tracks);
    RACSignal *filteredTracksSignal = RACObserve(self.tracksViewModel, filteredTracks);

    RACSignal *activeTracksSignal = [[RACObserve(self, searchController) flattenMap:^RACStream *(UISearchDisplayController *c) {
        return RACObserve(c, active);
    }] flattenMap:^RACStream *(NSNumber *active) {
        return active.boolValue ? filteredTracksSignal : tracksSignal;
    }];

    RACSignal *mergedS = [RACSignal combineLatest:@[
            [RACSignal merge:@[prevS, nextS, absoluteS]],
            activeTracksSignal
    ]];

    RACSignal *trackIdxS = [mergedS scanWithStart:@0
                                           reduce:^id(NSNumber *running, RACTuple *tuple) {
                                               RACTupleUnpack(NextFn next, NSArray *tracks) = tuple;
                                               NSInteger trackCount = tracks.count;
                                               NSInteger i = next(running.integerValue);
                                               return @(mod(i, trackCount));
                                           }];

    [trackIdxS subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];

    @weakify(self)
    [[RACSignal merge:@[trackIdxS]] subscribeNext:^(NSNumber *trackIndex) {
        @strongify(self)
        NSArray *tracks = self.searchController.active ? self.tracksViewModel.filteredTracks : self.tracksViewModel.tracks;
        id<MUMTrack> track = tracks[trackIndex.unsignedIntegerValue];
        [self.currentTrack stop];
        self.currentTrack = track;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:trackIndex.integerValue inSection:0];
        UITableView *tableView = self.searchController.active ? self.searchController.searchResultsTableView : self.tableView;
        [tableView selectRowAtIndexPath:indexPath animated:YES
                              scrollPosition:UITableViewScrollPositionMiddle];
        [track play];

        // TODO - don't update duration/elapsed before track is ready ...
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:@{
                MPMediaItemPropertyTitle : [track trackDescription],
                MPMediaItemPropertyArtwork : [[MPMediaItemArtwork alloc] initWithImage:[[track class] sourceImage]],
                MPMediaItemPropertyPlaybackDuration : track.client.currentTrackDuration,
                // This isn't strictly necessary, as elapsed time is always zero at this point,
                // and the current time is extrapolated
                MPNowPlayingInfoPropertyElapsedPlaybackTime : track.client.elapsed
        }];

    }];

    RACSignal *playPause = [remoteControlSignal filter:^BOOL(UIEvent *event) {
        return event.subtype == UIEventSubtypeRemoteControlTogglePlayPause;

    }];

    [playPause subscribeNext:^(id x) {
        @strongify(self)
        if(self.currentTrack.client.playing){
            [self.currentTrack stop];
        } else {
            [self.currentTrack play];
        }
    }];
    return self;
}

- (void)setup {

    // Filtering
    RACSignal *filterSignal = [[[self rac_signalForSelector:@selector(searchDisplayController:shouldReloadTableForSearchString:)
                                                fromProtocol:@protocol(UISearchDisplayDelegate)] map:^id(RACTuple *tuple) {
            return tuple.second;
        }] map:^id(NSString *searchString) {
            return searchString.length>0 ? searchString : nil;
        }];

    RAC(self.tracksViewModel,filter) = filterSignal;

    // Refreshing
    RACSignal *refreshSignal = [self.refreshControl rac_signalForControlEvents:UIControlEventValueChanged];
    RACSignal *trigger = [refreshSignal startWith:nil];

    [self.tracksViewModel rac_liftSelector:@selector(reload:) withSignalsFromArray:@[trigger]];


    // Adding to vc queue
    NSArray *clientSignals = [[self.tracksViewModel.clients filterUsingBlock:^BOOL(NSObject *client) {
        return [client respondsToSelector:@selector(wantsPresentingViewController)];
    }] mapUsingBlock:^id(id<MUMClient> client) {
        return [[RACObserve(client, wantsPresentingViewController) ignore:@NO] mapReplace:client];
    }];

    RAC(self,clientsWantingViewController) = [[RACSignal merge:clientSignals] scanWithStart:@[]
                                                                                     reduce:^id(id running, id client) {
                                                                                         return [running arrayByAddingObject:client];
                                                                                     }];

    // Removing from queue
    RACSignal *presentingVCSignal = [[self rac_signalForSelector:@selector(viewDidAppear:)] mapReplace:self];

    // TODO - combine this with adding to the queue
    @weakify(self)
    [presentingVCSignal subscribeNext:^(id viewController) {
        @strongify(self)
        id <MUMClient> client = self.clientsWantingViewController.lastObject;
        NSCAssert(!client.presentingViewController,@"client already has the presenting vc?");
        [self.clientsWantingViewController enumerateObjectsUsingBlock:^(id <MUMClient> c, NSUInteger idx, BOOL *stop) {
            c.presentingViewController = nil;
        }];
        client.presentingViewController = viewController;
        self.clientsWantingViewController = [self.clientsWantingViewController arrayByRemovingLastObject];
    }];


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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.refreshControl = [UIRefreshControl new];

    [self.tableView registerClass:[MUMTrackCell class]];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    @weakify(self)

    [[RACObserve(self.tracksViewModel, tracks) ignore:nil] subscribeNext:^(id x) {
        @strongify(self)
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
    } error:^(NSError *error) {
        NSLog(@"%@", error);
    } completed:^{
        NSLog(@"completed");
    }];

    [[[RACObserve(self.tracksViewModel,filter) ignore:nil] throttle:0.1] subscribeNext:^(id x) {
        @strongify(self)
        [self.searchController.searchResultsTableView reloadData];
    } error:^(NSError *error) {
        NSLog(@"%@", error);
    } completed:^{
        NSLog(@"completed");
    }];

    self.searchBar = [UISearchBar new];
    self.searchBar.delegate = self;
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsDelegate = self;
    self.searchController.delegate = self;

    [self.searchController.searchResultsTableView registerClass:[MUMTrackCell class]];

    self.tableView.tableHeaderView = self.searchBar;

}


#pragma tableview

- (NSArray *)tracksForTableView:(UITableView *)tableView
{
    return tableView==self.searchController.searchResultsTableView ? self.tracksViewModel.filteredTracks : self.tracksViewModel.tracks;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        NSArray *tracks = [self tracksForTableView:tableView];
        return tracks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *tracks = [self tracksForTableView:tableView];
    id<MUMTrack> track = tracks[(NSUInteger) indexPath.row];
    MUMTrackCell *cell = [tableView dequeueReusableCellWithClass:[MUMTrackCell class]];
    [cell configure:track];
    return cell;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];

    [self becomeFirstResponder];

    NSLog(@"didappear");
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}


#pragma mark - UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    return NO;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{

}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

@end
