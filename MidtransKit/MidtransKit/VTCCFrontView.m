//
//  VTCCFrontView.m
//  MidtransKit
//
//  Created by Nanang Rafsanjani on 3/6/16.
//  Copyright © 2016 Veritrans. All rights reserved.
//

#import "VTCCFrontView.h"

@implementation VTCCFrontView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _deleteButton.hidden = YES;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _deleteButton.hidden = YES;
    }
    return self;
}

@end
