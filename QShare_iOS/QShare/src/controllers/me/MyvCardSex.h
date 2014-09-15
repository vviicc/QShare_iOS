//
//  MyvCardSex.h
//  QShare
//
//  Created by Vic on 14-6-4.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyvCardDelegate.h"

@interface MyvCardSex : UITableViewController

@property (nonatomic) NSString *sex;
@property (nonatomic,weak) id<MyvCardDelegate> delegate;

@end
