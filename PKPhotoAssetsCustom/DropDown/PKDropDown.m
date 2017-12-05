//
//  PKDropDown.m
//  PKDropDown
//
//  Created by Pawan kumar on 12/3/17.
//  Copyright © 2017 Pawan Kumar. All rights reserved.
//

#import "PKDropDown.h"

@interface PKDropDown () <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *dropdowntable;
    UIFont *selectedFont, *font, *itemFont;
    BOOL isCollapsed;
    UITapGestureRecognizer *tapGestureBackground;
    UILabel *label;
}

@end

@implementation PKDropDown

- (instancetype)init {
    if (self = [super init])
        [self initLayer];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder])
        [self initLayer];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame])
        [self initLayer];
    return self;
}

- (void)initLayer {
    
    isCollapsed = TRUE;
    _itemTextAlignment = _titleTextAlignment = NSTextAlignmentCenter;
    _titleColor = [UIColor blackColor];
    _titleFontSize = 14.0;
    _itemHeight = 40.0;
    _itemTextColor = [UIColor blackColor];
    _itemFontSize = 14.0;
    _itemsFont = [UIFont systemFontOfSize:14.0];
    _directionDropDown = YES;
    _displayKeyName = @"";
}

#pragma mark - Setter

-(void)setTitle:(NSString *)title{
    _title = title;
}

-(void)setTitleTextAlignment:(NSTextAlignment)titleTextAlignment{
    if(titleTextAlignment)
        _titleTextAlignment = titleTextAlignment;
}

-(void)setItemTextAlignment:(NSTextAlignment)itemTextAlignment{
    if(itemTextAlignment)
        _itemTextAlignment = itemTextAlignment;
}

-(void)setTitleColor:(UIColor *)titleColor{
    if(titleColor)
        _titleColor = titleColor;
}

-(void)setTitleFontSize:(CGFloat)titleFontSize{
    if(titleFontSize)
        _titleFontSize = titleFontSize;
    
}

-(void)setItemHeight:(double)itemHeight{
    if(itemHeight)
        _itemHeight = itemHeight;
}

-(void)setItemTextColor:(UIColor *)itemTextColor{
    if(itemTextColor)
        _itemTextColor = itemTextColor;
}

-(void)setItemFontSize:(CGFloat)itemFontSize{
    if(itemFontSize)
        _itemFontSize = itemFontSize;
}

-(void)setItemsFont:(UIFont *)itemFont1{
    if(itemFont1)
        _itemsFont = itemFont1;
}

-(void)setDirectionDown:(BOOL)DirectionDown{
    _directionDropDown = DirectionDown;
}

#pragma mark - Setups

-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.layer.cornerRadius = 4;
    self.layer.borderColor = [[UIColor grayColor] CGColor];
    self.layer.borderWidth = 1;
    
    if(label == nil){
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        label.textColor = _titleColor;
        label.text = _title;
        label.textAlignment = _titleTextAlignment;
        label.font = font;
        [self addSubview:label];
    }
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    [self addGestureRecognizer:tapGesture];
    

    dropdowntable = [[UITableView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height)] ;
    [dropdowntable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    dropdowntable.delegate = self;
    dropdowntable.dataSource = self;
    dropdowntable.backgroundColor = [UIColor whiteColor];;
}

-(void)didTap : (UIGestureRecognizer *)gesture {
    isCollapsed = !isCollapsed;
    if(!isCollapsed) {
        CGFloat height = (CGFloat)(_items.count > 5 ? _itemHeight*5 : _itemHeight * (double)(_items.count));
        
        dropdowntable.layer.zPosition = 1;
        [dropdowntable removeFromSuperview];
        dropdowntable.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        dropdowntable.layer.borderWidth = 1;
        dropdowntable.layer.cornerRadius = 4;
        [self.superview addSubview:dropdowntable];
        [dropdowntable reloadData];
        
        [UIView animateWithDuration:0.25 animations:^{
            
            if(_directionDropDown)
                dropdowntable.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height+5, self.frame.size.width, height);
            else
                dropdowntable.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y - 5 - height, self.frame.size.width, height);
        }];
        
        if(_delegate != nil){
            if([_delegate respondsToSelector:@selector(show:)])
                [_delegate show:self];
        }
        
        UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        view.tag = 99121;
        [self.superview insertSubview:view belowSubview:dropdowntable];
        
        tapGestureBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapBackground:)];
        [view addGestureRecognizer:tapGestureBackground];
        
    }
    else{
        [self collapseTableView];
    }
}

-(void)didTapBackground : (UIGestureRecognizer *)gesture {
    isCollapsed = TRUE;
    [self collapseTableView];
}

-(void)collapseTableView{
    if(isCollapsed){
        [UIView animateWithDuration:0.25 animations:^{
            
            if(_directionDropDown)
                dropdowntable.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height+5, self.frame.size.width, 0);
            else
                dropdowntable.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 0);
        }];
        
        [[self.superview viewWithTag:99121] removeFromSuperview];
        
        if(_delegate != nil){
            if([_delegate respondsToSelector:@selector(hide:)])
                [_delegate hide:self];
        }
        
    }
}

#pragma mark - UITableView's Delegate and Datasource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _items.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.textAlignment = _itemTextAlignment;
    
    if ([_items[indexPath.row] objectForKey:_displayKeyName]) {
        
        cell.textLabel.text = [_items[indexPath.row] objectForKey:_displayKeyName];
    }else{
        cell.textLabel.text = _items[indexPath.row];
    }

    cell.textLabel.font = _itemsFont;
    cell.textLabel.textColor = _itemTextColor;
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.tintColor = self.tintColor;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return _itemHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if ([_items[indexPath.row] objectForKey:_displayKeyName]) {
        label.text = [_items[indexPath.row] objectForKey:_displayKeyName];
    }else{
        label.text = _items[indexPath.row];
    }
    
    isCollapsed = TRUE;
    [self collapseTableView];
    if(_delegate != nil){
        if([_delegate respondsToSelector:@selector(didSelectItem:index:)])
            [_delegate didSelectItem:self index:(int)indexPath.row];
    }
    
}

@end
