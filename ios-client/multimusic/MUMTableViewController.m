//
// Created by Mikkel Gravgaard on 15/03/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import <NSArray+Functional/NSArray+Functional.h>
#import "MUMTableViewController.h"
#import "MUMViewModel.h"
#import "UITableView+MUMAdditions.h"
#import "MUMTrackCell.h"
#import "LocalTrack.h"
#import "MUMSpotifyClient.h"
#import "MUMSoundCloudClient.h"
#import "MUMLocalClient.h"
#import "NSArray+MUMAdditions.h"

typedef NSInteger(^NextFn)(NSInteger);

@interface MUMTableViewController () <UISearchBarDelegate, UISearchDisplayDelegate>
@property (nonatomic, strong) MUMViewModel *tracksViewModel, *searchViewModel;
@property (nonatomic, strong) id<MUMTrack> currentTrack;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (strong, nonatomic) UISearchDisplayController *searchController;
@property (nonatomic, strong) NSArray *clientsWantingViewController;
@property (nonatomic) NSInteger playingTrackIndex;
@end

@implementation MUMTableViewController {

}

int mod(int a, int b)
{
    return ((a % b) + b) % b;
}

- (instancetype)init {
    if (!(self = [super init])) return nil;
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


    RACSignal *racSignal = [RACSignal combineLatest:@[
            [RACSignal merge:@[prevS, nextS, absoluteS]],
            RACObserve(self.tracksViewModel,tracks)
    ]];

    RACSignal *trackIdxS = [racSignal scanWithStart:@0
                                             reduce:^id(NSNumber *running, RACTuple *tuple) {
                                                 RACTupleUnpack(NextFn next, NSArray *tracks) = tuple;
                                                 NSInteger trackCount = tracks.count;
                                                 NSInteger i = next(running.integerValue);
                                                 return @(mod(i,trackCount));
                                             }];

    [trackIdxS subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];

    @weakify(self)
    [[RACSignal merge:@[trackIdxS]] subscribeNext:^(NSNumber *trackIndex) {
        @strongify(self)
        NSArray *tracks = [[self viewModelForTableView:self.tableView] tracks];
        id<MUMTrack> track = tracks[trackIndex.unsignedIntegerValue];
        [self.currentTrack stop];
        self.currentTrack = track;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:trackIndex.integerValue inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath animated:YES
                              scrollPosition:UITableViewScrollPositionMiddle];
        [track play];
    }];

    return self;
}

- (void)setup {
    NSArray *clients = @[
            [MUMLocalClient new],
            [MUMSoundCloudClient new],
            [MUMSpotifyClient new]
    ];


    RACSignal *searchSignal = [[[[self rac_signalForSelector:@selector(searchDisplayController:shouldReloadTableForSearchString:)
                                                                    fromProtocol:@protocol(UISearchDisplayDelegate)] map:^id(RACTuple *tuple) {
            return tuple.second;
        }] filter:^BOOL(NSString *searchString) {
            return searchString.length>2;
        }] throttle:0.5];

    self.searchViewModel = [MUMViewModel searchViewModelWithClients:clients
                                                       searchSignal:searchSignal];

    // TODO - this would have been easier by concatenating with the signalForControlEvents directly,
    // but that messes up the KVO for some reason ...
    RACSubject *refreshSubject = [RACSubject subject];
    RACSignal *trigger = [[RACSignal return:nil] concat:refreshSubject];
    self.tracksViewModel = [MUMViewModel tracklistingViewModelWithClients:clients loadTrigger:trigger];

    @weakify(refreshSubject)
    [[[self refreshControl] rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(id x) {
        @strongify(refreshSubject)
        [refreshSubject sendNext:nil];
    }];


    // Adding to vc queue
    NSArray *clientSignals = [[clients filterUsingBlock:^BOOL(NSObject *client) {
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


    [self.refreshControl addTarget:self action:@selector(refresh:)
                  forControlEvents:UIControlEventValueChanged];

}

- (void)refresh:(id)refresh {
    NSLog(@"funk");
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

    [[RACObserve(self.searchViewModel, tracks) ignore:nil] subscribeNext:^(id x) {
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

- (MUMViewModel *)viewModelForTableView:(UITableView *)tableView
{
    return tableView==self.searchController.searchResultsTableView ? self.searchViewModel : self.tracksViewModel;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        NSArray *tracks = [[self viewModelForTableView:tableView] tracks];
        return tracks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *tracks = [[self viewModelForTableView:tableView] tracks];
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