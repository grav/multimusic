//
// Created by Mikkel Gravgaard on 03/05/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import "MUMMenuViewController.h"
#import "MUMViewModel.h"
#import "MUM.h"
#import "MUMClientCell.h"


@interface MUMMenuViewController () <UITableViewDataSource, UITableViewDelegate>
@property(nonatomic, strong) MUMViewModel *viewModel;
@end

@implementation MUMMenuViewController {

}

- (instancetype)initWithViewModel:(MUMViewModel *)viewModel {
    if (!(self = [super init])) return nil;
    self.viewModel = viewModel;
    return self;
}


- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor orangeColor];
    UILabel *label = [UILabel new];
    label.text = @"Here be menu";
    [self.view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(label.superview);
    }];

    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(tableView.superview);
    }];

}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.clients.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id<MUMClient> client = self.viewModel.clients[(NSUInteger) indexPath.row];
    MUMClientCell *cell = [[MUMClientCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:@"whatever"];
    cell.textLabel.text = client.name;
    cell.imageView.image = [(NSObject*)client respondsToSelector:@selector(logo)] ? client.logo : nil;

    cell.clientEnabled = client.enabled;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id<MUMClient> client = self.viewModel.clients[(NSUInteger) indexPath.row];
    client.enabled = !client.enabled;
    MUMClientCell *cell = (MUMClientCell *) [tableView cellForRowAtIndexPath:indexPath];
    cell.clientEnabled = client.enabled;
    [self.viewModel reload:nil];
}


@end