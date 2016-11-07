//
//  MainSecondTableViewCell.h
//  e-Healthy
//
//  Created by FangLin on 16/11/4.
//  Copyright © 2016年 FangLin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MainSecondTableViewCell <NSObject>

-(void)tapClick:(NSInteger)number;

@end

@interface MainSecondTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *oneView;
@property (weak, nonatomic) IBOutlet UIView *twoView;
@property (weak, nonatomic) IBOutlet UILabel *serveLabel;
@property (weak, nonatomic) IBOutlet UILabel *introductOneLabel;
@property (weak, nonatomic) IBOutlet UIImageView *serveImageView;
@property (weak, nonatomic) IBOutlet UILabel *knowledgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *introductTwoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *knowledgeImageView;

@property (nonatomic,strong)id<MainSecondTableViewCell> delegate;

@end
