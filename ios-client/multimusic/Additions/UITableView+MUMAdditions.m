//
// Created by Mikkel Gravgaard on 15/03/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa/RACSignal.h>
#import "UITableView+MUMAdditions.h"


@implementation UITableView (MUMAdditions)


+ (NSString *)classToReuseId:(Class)class
{
    return [NSString stringWithFormat:@"%@-ReuseIdentifier",[class description]];
}

- (void)registerClass:(Class)cellClass {
    [self registerClass:cellClass forCellReuseIdentifier:[UITableView classToReuseId:cellClass]];
}

- (id)dequeueReusableCellWithClass:(Class)class
{
    return [self dequeueReusableCellWithIdentifier:[UITableView classToReuseId:class]];
}

- (void)reloadWithBang:(RACSignal *)_
{
    [self reloadData];
}

@end