//
//  MyvCardSex.m
//  QShare
//
//  Created by Vic on 14-6-4.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import "MyvCardSex.h"

@interface MyvCardSex ()
@property (weak, nonatomic) IBOutlet UIImageView *manCheckMark;
@property (weak, nonatomic) IBOutlet UIImageView *womanCheckMark;

@end

@implementation MyvCardSex

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSex];
}

- (void)setupSex
{
    if (_sex) {
        if ([_sex isEqualToString:@"男"]) {
            _womanCheckMark.hidden = YES;
        }
        else{
            _manCheckMark.hidden = YES;
        }
    }
    else{
        _manCheckMark.hidden = YES;
        _womanCheckMark.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        [_delegate didSelectMan:YES];
    }
    else
    {
        [_delegate didSelectMan:NO];

    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
}


@end
