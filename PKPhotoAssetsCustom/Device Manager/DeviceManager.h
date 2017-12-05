//
//  DeviceManager.h
//  MWM
//
//  Created by Pawan kumar on 2/7/17.
//  Copyright © 2017 Pawan kumar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface DeviceManager : NSObject

+(DeviceManager *)shared;

#pragma mark - openSchemePermission
- (void)openSchemePermission:(NSString *)scheme;

#pragma mark - Permissions
-(void)cameraPermissionOpenSetting;
-(void)photosPermissionOpenSetting;
-(BOOL)checkCameraPermission;
-(BOOL)checkPhotoPermission;

//Featch All Photos With Folder
@property (nonatomic) NSMutableArray *allAlbums;

@property NSMutableArray *objects;
@property (strong) NSArray *collectionsFetchResults;
@property (strong) NSArray *collectionsLocalizedTitles;
@property (nonatomic) NSArray *collectionsArrays;

@property (nonatomic) NSArray *allgroupNames;

- (void)featchallPhotos;

@end

