//
//  PKDropDown.h
//  PKDropDown
//
//  Created by Pawan kumar on 12/3/17.
//  Copyright © 2017 Pawan Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PKDropDown;

@protocol PKDropDownDelegate <NSObject>

@optional

-(void)didSelectItem:(PKDropDown *)dropMenu index:(long)index;
-(void)show:(PKDropDown *)dropMenu;
-(void)hide:(PKDropDown *)dropMenu;

@end

@interface PKDropDown : UIView

@property (nonatomic, retain) id <PKDropDownDelegate> delegate;

@property (nonatomic, retain) NSString *displayKeyName;

@property (nonatomic, retain) IBInspectable NSString *title;
@property (nonatomic, retain) IBInspectable UIColor *titleColor;
@property (nonatomic) IBInspectable CGFloat titleFontSize;
@property (nonatomic) IBInspectable double itemHeight;

@property (nonatomic, retain) IBInspectable UIColor *itemTextColor;
@property (nonatomic) IBInspectable CGFloat itemFontSize;
@property (nonatomic)  UIFont *itemsFont;
@property (nonatomic) NSTextAlignment titleTextAlignment;
@property (nonatomic) NSTextAlignment itemTextAlignment;
@property (nonatomic, retain) NSArray *items;

/* YES(On) = Down and NO(Off) = Up */
@property (nonatomic) IBInspectable BOOL directionDropDown;


@end
