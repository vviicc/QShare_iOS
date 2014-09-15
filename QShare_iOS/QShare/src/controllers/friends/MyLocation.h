//
//  MyLocation.h
//  QShare
//
//  Created by Vic on 14-7-22.
//  Copyright (c) 2014年 vic. All rights reserved.
//


#import <UIKit/UIKit.h>

@protocol MyLocationDelegate <NSObject>

-(void)sendLocationImage:(UIImage *)image andLongitude:(double)longitude andLatitude:(double)latitude;

@end

@interface MyLocation : UIViewController

@property (nonatomic,weak) id<MyLocationDelegate> delegate;

@end
