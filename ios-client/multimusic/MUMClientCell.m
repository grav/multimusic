//
// Created by Mikkel Gravgaard on 29/06/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import "MUMClientCell.h"


@implementation MUMClientCell {

}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        @weakify(self)
        [RACObserve(self, clientEnabled) subscribeNext:^(NSNumber *n) {
            @strongify(self)
            BOOL enabled = n.boolValue;
            self.textLabel.textColor = enabled ? [UIColor blackColor] : [UIColor grayColor];
            self.textLabel.font = enabled ? [UIFont systemFontOfSize:10]: [UIFont italicSystemFontOfSize:10];
        }];
    }

    return self;
}


@end