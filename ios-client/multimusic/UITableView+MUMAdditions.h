//
// Created by Mikkel Gravgaard on 15/03/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UITableView (MUMAdditions)


- (void)registerClassAndReuseIdentifier:(Class)cellClass;

- (id)dequeueReusableCellWithClass:(Class)class;

- (void)reloadWithBang:(id)_;
@end