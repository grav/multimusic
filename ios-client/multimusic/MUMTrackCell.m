//
// Created by Mikkel Gravgaard on 15/03/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import "MUMTrackCell.h"
#import "LocalTrack.h"
#import "MUM.h"
@interface MUMTrackCell ()
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UILabel *addView;
@end

@implementation MUMTrackCell {

}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.icon = [UIImageView new];
        [self.contentView addSubview:self.icon];
        [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.icon.superview).offset(5);
            make.top.equalTo(self.icon.superview).offset(5);
            make.bottom.equalTo(self.icon.superview).offset(-5);
            make.height.equalTo(self.icon.mas_width);
        }];


        self.addView = [UILabel new];
        [self.contentView addSubview:self.addView];
        [self.addView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.addView.superview);
            make.right.equalTo(self.addView.superview).offset(-5);

        }];
        self.addView.font = [UIFont systemFontOfSize:16];
        [self.addView setContentHuggingPriority:UILayoutPriorityDefaultHigh
                                        forAxis:UILayoutConstraintAxisHorizontal];

        self.label = [UILabel new];
        self.label.font = [UIFont systemFontOfSize:11];
        [self.contentView addSubview:self.label];

        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.label.superview);
            make.left.equalTo(self.icon.mas_right).offset(10);
            make.right.equalTo(self.addView.mas_left).offset(-10);
        }];


    }

    return self;
}


- (void)configure:(id <MUMTrack>)track {
    self.icon.image = [[track class] sourceImage];
    self.label.text = track.trackDescription;
    self.addView.text = @"+";

}


@end