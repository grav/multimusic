//
// Created by Mikkel Gravgaard on 03/05/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import "MUMMenuViewController.h"


@implementation MUMMenuViewController {

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
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end