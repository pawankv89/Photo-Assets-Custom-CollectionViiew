//
//  DeviceManager.m
//  MWM
//
//  Created by Pawan kumar on 2/7/17.
//  Copyright © 2017 Pawan kumar. All rights reserved.
//

#import "DeviceManager.h"
#import "AppDelegate.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

@implementation DeviceManager

+(DeviceManager *)shared
{
    static dispatch_once_t once;
    static DeviceManager * singleton;
    dispatch_once(&once, ^ { singleton = [[DeviceManager alloc] init]; });
    return singleton;
}

//Init Singaltone class
- (id)init
{
    if (self = [super init]){
        
        //All Albums
        self.allAlbums = [NSMutableArray new];
    }
    return self;
}

#pragma mark - OpenSchemePermission
- (void)openSchemePermission:(NSString *)scheme {
    
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *URL = [NSURL URLWithString:scheme];
    
    if ([[UIApplication sharedApplication] canOpenURL:URL]) {
        
        if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
            
            if (@available(iOS 10.0, *)) {
                [application openURL:URL options:@{}
                   completionHandler:^(BOOL success) {
                       
                       NSLog(@"Open %@: %d",scheme,success);
                       
                   }];
            } else {
                // Fallback on earlier versions
            }
        } else {
            
            BOOL success = [application openURL:URL];
            
            NSLog(@"Open %@: %d",scheme,success);
        }
        
    }else{}
}

-(void)cameraPermissionOpenSetting{
    
    //Show AlertView
    NSString *alert_titel = @"Can't access camera";
    NSString *alert_message = @"You have to access the camera to use this App. To access, please go to Settings->Privacy->Camera";
    NSString *alert_Ok = @"Setting";
    NSString *alert_Cancel = @"Cancel";
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:alert_titel
                                 message:alert_message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:alert_Ok
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             //Open Setting
                             [self openSchemePermission:UIApplicationOpenSettingsURLString];
                             
                             NSLog(@"Resolving UIAlert Action for tapping Yes Button");
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:alert_Cancel
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 NSLog(@"Resolving UIAlertActionController for tapping No button");
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    AppDelegate *appDelegate =  [AppDelegate sharedInstance];//sharedInstance
    [appDelegate.window.rootViewController presentViewController:alert animated:YES completion:nil];
}

-(void)photosPermissionOpenSetting{
    
    //Show AlertView
    NSString *alert_titel = @"Can't access photos";
    NSString *alert_message = @"You have to access the photos to use this App. To access, please go to Settings->Privacy->Photos";
    NSString *alert_Ok = @"Setting";
    NSString *alert_Cancel = @"Cancel";
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:alert_titel
                                 message:alert_message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:alert_Ok
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             //Open Setting
                             [self openSchemePermission:UIApplicationOpenSettingsURLString];
                             
                             NSLog(@"Resolving UIAlert Action for tapping Yes Button");
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:alert_Cancel
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 NSLog(@"Resolving UIAlertActionController for tapping No button");
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    AppDelegate *appDelegate =  [AppDelegate sharedInstance];
    [appDelegate.window.rootViewController presentViewController:alert animated:YES completion:nil];
    
}


-(BOOL)checkCameraPermission{
    
    BOOL camera = YES;
    
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        // do your logic
    } else if(authStatus == AVAuthorizationStatusDenied){
        // denied
        
        camera = NO;
        
    } else if(authStatus == AVAuthorizationStatusRestricted){
        // restricted, normally won't happen
    } else if(authStatus == AVAuthorizationStatusNotDetermined){
        // not determined?!
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            if(granted){
                NSLog(@"Granted access to %@", mediaType);
            } else {
                NSLog(@"Not granted access to %@", mediaType);
            }
        }];
    } else {
        // impossible, unknown authorization status
    }
    
    return camera;
}

-(BOOL)checkPhotoPermission{
    
    BOOL photos = YES;
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusAuthorized) {
        // Access has been granted.
        
    }
    
    else if (status == PHAuthorizationStatusDenied) {
        // Access has been denied.
        
        photos = NO ;
    }
    
    else if (status == PHAuthorizationStatusNotDetermined) {
        
        // Access has not been determined.
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
            if (status == PHAuthorizationStatusAuthorized) {
                // Access has been granted.
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self featchallPhotos];
                });
            }
            
            else {
                // Access has been denied.
                
            }
        }];
    }
    
    else if (status == PHAuthorizationStatusRestricted) {
        // Restricted access - normally won't happen.
    }
    
    return photos;
}


- (void)featchallPhotos
{
    
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    [options setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(localizedTitle)) ascending:YES]]];
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:options];
    self.collectionsFetchResults = @[topLevelUserCollections, smartAlbums];
    self.collectionsLocalizedTitles = @[NSLocalizedString(@"Albums", @""), NSLocalizedString(@"Smart Albums", @"")];
    
    [self excludeEmptyCollections];
    
    [self photoLibraryDidChangeNotification];
    
    
}


- (void)excludeEmptyCollections {
    NSMutableArray *collectionsArray = [NSMutableArray array];
    for (PHFetchResult *result in self.collectionsFetchResults) {
        NSMutableArray *filteredCollections = [NSMutableArray array];
        [result enumerateObjectsUsingBlock:^(PHAssetCollection *obj, NSUInteger idx, BOOL *stop) {
            PHFetchOptions *options = [[PHFetchOptions alloc] init];
            [options setPredicate:[NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage]];
            if ([obj isKindOfClass:[PHAssetCollection class]]) {
                if ([self hasImageTypeAssetInCollection:(PHAssetCollection *)obj]) {
                    [filteredCollections addObject:obj];
                }
            } else if ([obj isKindOfClass:[PHCollectionList class]]) {
                NSMutableArray *array = [self doExtractAssetCollectionsFrom:(PHCollectionList *)obj];
                [filteredCollections addObjectsFromArray: array];
            }
        }];
        [collectionsArray addObject:filteredCollections];
    }
    self.collectionsArrays = collectionsArray;
}

- (BOOL)hasImageTypeAssetInCollection: (PHAssetCollection *)collection {
    PHFetchOptions *assetOptions = [[PHFetchOptions alloc] init];
    [assetOptions setPredicate:[NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage]];
    PHFetchResult *countResult = [PHAsset fetchAssetsInAssetCollection:collection options:assetOptions];
    
    return countResult.count > 0;
}

- (NSMutableArray *)doExtractAssetCollectionsFrom: (PHCollectionList *) collectionList {
    NSMutableArray *filteredCollections = [NSMutableArray array];
    
    PHFetchOptions *collectionOptions = [[PHFetchOptions alloc] init];
    [collectionOptions setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(localizedTitle)) ascending:YES]]];
    PHFetchResult *result = [PHCollection fetchCollectionsInCollectionList:collectionList options:collectionOptions];
    
    [result enumerateObjectsUsingBlock:^(PHCollection *obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[PHAssetCollection class]]) {
            if ([self hasImageTypeAssetInCollection:(PHAssetCollection *)obj]) {
                [filteredCollections addObject:obj];
            }
        } else if ([obj isKindOfClass:[PHCollectionList class]]) {
            NSMutableArray *array = [self doExtractAssetCollectionsFrom:(PHCollectionList *)obj];
            [filteredCollections addObjectsFromArray:array];
        }
    }];
    
    return filteredCollections;
}

-(void)photoLibraryDidChangeNotification{
    
    [DeviceManager shared].allAlbums = [NSMutableArray new];
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage];
    
    PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsWithOptions:options];//"All Photos"
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    //Set Object
    [dict setObject:@"All Photos" forKey:@"Name"];
    [dict setObject:assetsFetchResult forKey:@"Photos"];
    [dict setObject:[NSString stringWithFormat:@"%ld", (long)[assetsFetchResult count]] forKey:@"Count"];
    
    [[DeviceManager shared].allAlbums addObject:dict];
    
    NSArray *collections = [DeviceManager shared].collectionsArrays[1];
    
    //Photo Picker all Albums
    for (int index = 0; index <[collections count]; index++) {
        
        NSMutableDictionary *dict = [NSMutableDictionary new];
        
        PHCollection *collection = collections[index];
        NSString *localizedTitle = collection.localizedTitle;
        NSLog(@"localizedTitle %@",localizedTitle);
        
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
            
            //Set Object
            [dict setObject:collection.localizedTitle forKey:@"Name"];
            [dict setObject:assetsFetchResult forKey:@"Photos"];
            [dict setObject:[NSString stringWithFormat:@"%ld", (long)[assetsFetchResult count]] forKey:@"Count"];
            
            [[DeviceManager shared].allAlbums addObject:dict];
        }
    }
    
    //Post Notification When load Photos
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PhotosLibraryNotification" object:nil];
}

@end

