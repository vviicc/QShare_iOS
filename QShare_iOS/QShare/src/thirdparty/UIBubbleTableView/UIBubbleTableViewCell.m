//
//  UIBubbleTableViewCell.m
//
//  Created by Alex Barinov
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import <QuartzCore/QuartzCore.h>
#import "UIBubbleTableViewCell.h"
#import "NSBubbleData.h"
#import "UMSocial.h"
#import "UIBubbleTableView.h"
#import "ChatVC.h"

@interface UIBubbleTableViewCell ()

@property (nonatomic, retain) UIView *customView;
@property (nonatomic, retain) UIImageView *bubbleImage;
@property (nonatomic, retain) UIImageView *avatarImage;

- (void) setupInternalData;

@end

@implementation UIBubbleTableViewCell

@synthesize data = _data;
@synthesize customView = _customView;
@synthesize bubbleImage = _bubbleImage;
@synthesize showAvatar = _showAvatar;
@synthesize avatarImage = _avatarImage;

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
	[self setupInternalData];
}

#if !__has_feature(objc_arc)
- (void) dealloc
{
    self.data = nil;
    self.customView = nil;
    self.bubbleImage = nil;
    self.avatarImage = nil;
    [super dealloc];
}
#endif

- (void)setDataInternal:(NSBubbleData *)value
{
	self.data = value;
	[self setupInternalData];
}

- (void) setupInternalData
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (!self.bubbleImage)
    {
#if !__has_feature(objc_arc)
        self.bubbleImage = [[[UIImageView alloc] init] autorelease];
#else
        self.bubbleImage = [[UIImageView alloc] init];        
#endif
        [self addSubview:self.bubbleImage];
    }
    
    NSBubbleType type = self.data.type;
    
    CGFloat width = self.data.view.frame.size.width;
    CGFloat height = self.data.view.frame.size.height;

    CGFloat x = (type == BubbleTypeSomeoneElse) ? 0 : self.frame.size.width - width - self.data.insets.left - self.data.insets.right;
    CGFloat y = 0;
    
    // Adjusting the x coordinate for avatar
    if (self.showAvatar)
    {
        [self.avatarImage removeFromSuperview];
#if !__has_feature(objc_arc)
        self.avatarImage = [[[UIImageView alloc] initWithImage:(self.data.avatar ? self.data.avatar : [UIImage imageNamed:@"missingAvatar.png"])] autorelease];
#else
        self.avatarImage = [[UIImageView alloc] initWithImage:(self.data.avatar ? self.data.avatar : [UIImage imageNamed:@"missingAvatar.png"])];
#endif
        self.avatarImage.layer.cornerRadius = 9.0;
        self.avatarImage.layer.masksToBounds = YES;
        self.avatarImage.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:0.2].CGColor;
        self.avatarImage.layer.borderWidth = 1.0;
        
        CGFloat avatarX = (type == BubbleTypeSomeoneElse) ? 2 : self.frame.size.width - 52;
        CGFloat avatarY = self.frame.size.height - 50;
        
        self.avatarImage.frame = CGRectMake(avatarX, avatarY, 50, 50);
        [self addSubview:self.avatarImage];
        
        CGFloat delta = self.frame.size.height - (self.data.insets.top + self.data.insets.bottom + self.data.view.frame.size.height);
        if (delta > 0) y = delta;
        
        if (type == BubbleTypeSomeoneElse) x += 54;
        if (type == BubbleTypeMine) x -= 54;
    }

    [self.customView removeFromSuperview];
    self.customView = self.data.view;
    self.customView.frame = CGRectMake(x + self.data.insets.left, y + self.data.insets.top, width, height);
    [self.contentView addSubview:self.customView];

    if (type == BubbleTypeSomeoneElse)
    {
        self.bubbleImage.image = [[UIImage imageNamed:@"bubbleSomeone.png"] stretchableImageWithLeftCapWidth:21 topCapHeight:14];

    }
    else {
        self.bubbleImage.image = [[UIImage imageNamed:@"bubbleMine.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:14];
    }

    self.bubbleImage.frame = CGRectMake(x, y, width + self.data.insets.left + self.data.insets.right, height + self.data.insets.top + self.data.insets.bottom);
}

-(BOOL) canPerformAction:(SEL)action withSender:(id)sender {
    return (action == @selector(copy:) || action == @selector(share:));
//    return (action == @selector(test:));

}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

/// this methods will be called for the cell menu items
-(void) share: (id) sender {
    NSDictionary *dataDict = [self cell2data:self];
    if (dataDict[@"text"]) {
        
        [UMSocialSnsService presentSnsIconSheetView:[self cell2ChatVC:self]
                                             appKey:UMAPPKEY
                                          shareText:dataDict[@"text"]
                                         shareImage:nil
                                    shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToTencent,nil]
                                           delegate:nil];
    }
    else if(dataDict[@"image"]){
        
        [UMSocialSnsService presentSnsIconSheetView:[self cell2ChatVC:self]
                                             appKey:UMAPPKEY
                                          shareText:@"图片分享 #圈享#"
                                         shareImage:dataDict[@"image"]
                                    shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToTencent,nil]
                                           delegate:nil];
    }

}

-(void) copy:(id)sender {
    NSDictionary *dataDict = [self cell2data:self];
    UIPasteboard *sharedPasteboard = [UIPasteboard generalPasteboard];
    if (dataDict[@"text"]) {
        [sharedPasteboard setString:dataDict[@"text"]];
    }
    else
        return;
}



-(NSDictionary *)cell2data:(UIBubbleTableViewCell *)cell{
    NSDictionary *dict = nil;
    NSBubbleData *bubbleData = cell.data;
    UIView *bubbleView = bubbleData.view;
    if ([bubbleView isKindOfClass:[UILabel class]]) {
        UILabel *bubbleLabel = (UILabel *)bubbleView;
        NSString *bubbleString = bubbleLabel.text;
        dict = @{@"text": bubbleString};
    }
    else if ([bubbleView isKindOfClass:[UIImageView class]]){
        UIImageView *bubbleImageView = (UIImageView *)bubbleView;
        UIImage *bubbleImage = bubbleImageView.image;
        dict = @{@"image": bubbleImage};
        
    }
    return dict;
}

-(ChatVC *)cell2ChatVC:(UIBubbleTableViewCell *)cell{
    
    id bubbleView = cell.superview;
    
    while (bubbleView && ![bubbleView isKindOfClass:[UIBubbleTableView class]]) {
        bubbleView = [bubbleView superview];
    }
    
    UIBubbleTableView *bubbleTableView = (UIBubbleTableView *)bubbleView;
    return (ChatVC *)bubbleTableView.bubbleDataSource;
    
    
}


@end
