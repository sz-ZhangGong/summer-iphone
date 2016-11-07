//
//  SearchView.m
//  rongXing
//
//  Created by cts on 16/8/31.
//  Copyright © 2016年 cts. All rights reserved.
//

#import "SearchView.h"

@implementation SearchView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        [self layoutSubView];
    }
    return self;
}


-(void)layoutSubView
{
    [self addSubview:self.searchBtn];
    [self addSubview:self.searchTF];
}

-(UIButton *)searchBtn
{
    if (_searchBtn == nil) {
        _searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _searchBtn.frame = CGRectMake(20, 10, 20, 20);
        _searchBtn.backgroundColor = [UIColor whiteColor];
        [_searchBtn setBackgroundImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    }
    return _searchBtn;
}

-(UITextField *)searchTF
{
    if (_searchTF == nil) {
        _searchTF = [[UITextField alloc] initWithFrame:CGRectMake(_searchBtn.current_x_w+10, 0,self.frame.size.width - _searchBtn.current_x_w-20, 40)];
        _searchTF.placeholder = @"输入科室 医院名称";
        _searchTF.backgroundColor = [UIColor whiteColor];
        _searchTF.returnKeyType = UIReturnKeyDefault;
        _searchTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        _searchTF.keyboardType = UIKeyboardTypeDefault;

    }
    return _searchTF;
}


@end
