//
//  MyvCardIntro.h
//  QShare
//
//  Created by Vic on 14-6-4.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyvCardDelegate.h"

@interface MyvCardIntro : UIViewController

@property (nonatomic,weak) id<MyvCardDelegate> delegate;
@property (nonatomic,strong) NSString *introduce;

@end
