
Photo Assets Custom CollectionViiew
=========

## Photo Assets Custom CollectionViiew.
------------
 Added Some screens here.
 
![](https://github.com/pawankv89/PKPhotoAssetsCustom/blob/master/Screens/1.png)
![](https://github.com/pawankv89/PKPhotoAssetsCustom/blob/master/Screens/2.png)
![](https://github.com/pawankv89/PKPhotoAssetsCustom/blob/master/Screens/3.png)
![](https://github.com/pawankv89/PKPhotoAssetsCustom/blob/master/Screens/4.png)
![](https://github.com/pawankv89/PKPhotoAssetsCustom/blob/master/Screens/5.png)

## Usage
------------
 iOS 9 Demo showing how to droodown on iPhone X Simulator in  Objective-C.


```objective-c

- (void)viewDidLoad {
[super viewDidLoad];
// Do any additional setup after loading the view, typically from a nib.

//default Configuration Array
self.photos = [PHFetchResult new];
self.imagesCache = [[NSCache alloc] init];

//DropDown Menu
[self configurationDropdown];

//Register CollectionView Cell
[self registerCell];

//Configuration Photos Picker
[self configurationPhotosAssets];
}

- (void)didReceiveMemoryWarning {
[super didReceiveMemoryWarning];
// Dispose of any resources that can be recreated.
}



-(void)configurationPhotosAssets{

//Post Notification When load Photos
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photosLibraryNotification:) name:@"PhotosLibraryNotification" object:nil];

//Check Photo Permission
if ([[DeviceManager shared] checkPhotoPermission]) {

[[DeviceManager shared] featchallPhotos];

}else{

[[DeviceManager shared] photosPermissionOpenSetting];
}
}

#pragma mark - Load all Photos
-(void)photosLibraryNotification:(id)sender{

//DropDown Menu
[self configurationDropdown];

if ([DeviceManager shared].allAlbums != nil) {

if ([[DeviceManager shared].allAlbums count]>0) {

//All Albums Photos
NSDictionary *dict = [[DeviceManager shared].allAlbums lastObject];

//default selected items in dropdown
if (_dropdown != nil) {
if(_dropdown.title != nil){
_dropdown.title = [dict objectForKey:@"Name"];
}
}

//Send Array Data
[self filterAllPhotosArray:[dict objectForKey:@"Photos"]];

}
}
}

-(void)filterAllPhotosArray:(PHFetchResult *)assetsFetchResults{

self.photos = assetsFetchResults;
[self.collectionView reloadData];
}

-(void)configurationDropdown{

NSArray *items = [DeviceManager shared].allAlbums;
_dropdown.backgroundColor = [UIColor whiteColor];
_dropdown.items = items;
_dropdown.title = @"Select items";
_dropdown.displayKeyName = @"Name";
_dropdown.itemsFont = [UIFont fontWithName:@"Arial-Regular" size:12.0];
_dropdown.titleTextAlignment = NSTextAlignmentCenter;
_dropdown.delegate = self;

//CollectionView Frame
self.collectionView.frame = CGRectMake(0, _dropdown.frame.origin.y+_dropdown.frame.size.height+20, self.view.frame.size.width, self.view.frame.size.height-(_dropdown.frame.origin.y+_dropdown.frame.size.height+20));
}

-(void)didSelectItem:(PKDropDown *)dropMenu index:(long)index{

dispatch_async(dispatch_get_main_queue(), ^{

//All Albums Photos
NSDictionary *dict = [[DeviceManager shared].allAlbums objectAtIndex:index];
//Send Array Data
[self filterAllPhotosArray:[dict objectForKey:@"Photos"]];

[self.collectionView reloadData];
});
}
-(void)show:(PKDropDown *)dropMenu{

}
-(void)hide:(PKDropDown *)dropMenu{

}

-(void)registerCell{

//Register Cell
UINib *cellNib = [UINib nibWithNibName:cellReuseIdentifier bundle:nil];
[self.collectionView registerNib:cellNib forCellWithReuseIdentifier:cellReuseIdentifier];

self.collectionView.dataSource = self;
self.collectionView.delegate = self;
[self.collectionView reloadData];
}

CGSize cellSize(UICollectionView *collectionView) {

int numberOfColumns = 3;

// this is to fix jerky scrolling in iPhone 6 plus
if ([[UIScreen mainScreen] scale] > 2) {
numberOfColumns = 4;
}

CGFloat collectionViewWidth = collectionView.frame.size.width;
CGFloat spacing = [(id)collectionView.delegate collectionView:collectionView layout:collectionView.collectionViewLayout minimumInteritemSpacingForSectionAtIndex:0];
CGFloat width = floorf((collectionViewWidth-spacing*(numberOfColumns-1))/(float)numberOfColumns);
return CGSizeMake(width, width);
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
return cellSize(collectionView);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
return 5.f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
return 5.0f;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
NSInteger count = self.photos.count;
return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellReuseIdentifier forIndexPath:indexPath];
[cell setIsAccessibilityElement:YES];

PHAsset *asset = [self.photos objectAtIndex:indexPath.row];

//For File Name
NSArray *resources = [PHAssetResource assetResourcesForAsset:asset];
NSString *orgFilename = [NSString stringWithFormat:@"%@",((PHAssetResource*)resources[0]).originalFilename];
NSString *fileURL = [NSString stringWithFormat:@"%@",[((PHAssetResource*)resources[0]) valueForKey:@"fileURL"]];
cell.title.text =[NSString stringWithFormat:@"%@", orgFilename];

//For Image Retriveing
if ([self.imagesCache objectForKey:asset.localIdentifier]) {
cell.imageView.image = [self.imagesCache objectForKey:asset.localIdentifier];
} else {
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
[options setVersion:PHImageRequestOptionsVersionCurrent];
[options setResizeMode:PHImageRequestOptionsResizeModeFast];
[options setDeliveryMode:PHImageRequestOptionsDeliveryModeOpportunistic];
CGSize size = cellSize(collectionView);
CGFloat scale = [[UIScreen mainScreen] scale];
size = CGSizeMake(size.width * scale, size.height * scale);
NSString *identifier = asset.localIdentifier;
__weak typeof (self) selfie = self;
[[PHImageManager defaultManager] requestImageForAsset:asset
targetSize:size
contentMode:PHImageContentModeAspectFill
options:options
resultHandler:^(UIImage *result, NSDictionary *info) {
dispatch_async(dispatch_get_main_queue(), ^{
cell.imageView.image = result;
if (![info[PHImageResultIsDegradedKey] boolValue]) {
[selfie.imagesCache setObject:result forKey:identifier];
}
});
}];
});
}

return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
return YES;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

PHAsset *asset = [self.photos objectAtIndex:indexPath.row];

dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
[options setVersion:PHImageRequestOptionsVersionCurrent];
[options setResizeMode:PHImageRequestOptionsResizeModeFast];
[options setDeliveryMode:PHImageRequestOptionsDeliveryModeOpportunistic];
CGSize size = CGSizeMake(600, 600);
CGFloat scale = [[UIScreen mainScreen] scale];
size = CGSizeMake(size.width * scale, size.height * scale);

[[PHImageManager defaultManager]  requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {

NSData *imageDataRetrive = [imageData copy];
NSLog(@"requestImageDataForAsset returned info(%@)", info);

long imageDataLength = imageDataRetrive.length;

NSString *imageSize =[NSString stringWithFormat:@"'%ld' Bytes",imageDataLength];

if (imageDataLength/1024 >= 1) {
imageSize =[NSString stringWithFormat:@"'%ld' Kb",imageDataLength/1024];
}if (imageDataLength/1024/1024 >= 1) {
imageSize =[NSString stringWithFormat:@"'%ld' Mb",imageDataLength/1024/1024];
}if (imageDataLength/1024/1024/1024 >= 1) {
imageSize =[NSString stringWithFormat:@"'%ld' Gb",imageDataLength/1024/1024/1024];
}

/*
long long fileSize = lenghtImageData;
NSString *displayFileSize = [NSByteCountFormatter stringFromByteCount:fileSize
countStyle:NSByteCountFormatterCountStyleFile];
NSLog(@"Display file size: %@", displayFileSize);
*/

if (imageDataLength/1024 >= 200) {
//Check 200 Kb of Size

UIAlertController * alert = [UIAlertController
alertControllerWithTitle:[NSString stringWithFormat:@"%@",imageSize]
message:@"High resolution image."
preferredStyle:UIAlertControllerStyleAlert];
UIAlertAction* yesButton = [UIAlertAction
actionWithTitle:@"Yes"
style:UIAlertActionStyleDefault
handler:^(UIAlertAction * action) {

}];

[alert addAction:yesButton];
[self presentViewController:alert animated:YES completion:nil];

}else{

UIAlertController * alert = [UIAlertController
alertControllerWithTitle:[NSString stringWithFormat:@"%@",imageSize]
message:@"Low resolution image. Not suitable for print. Would you still want to process?"
preferredStyle:UIAlertControllerStyleAlert];
UIAlertAction* yesButton = [UIAlertAction
actionWithTitle:@"Yes"
style:UIAlertActionStyleDefault
handler:^(UIAlertAction * action) {

}];
UIAlertAction* noButton = [UIAlertAction
actionWithTitle:@"No"
style:UIAlertActionStyleDefault
handler:^(UIAlertAction * action) {

}];

[alert addAction:yesButton];
[alert addAction:noButton];

[self presentViewController:alert animated:YES completion:nil];

}
}];
});
}
```

```objective-c

```

## License

This code is distributed under the terms and conditions of the [MIT license](LICENSE).

## Change-log

A brief summary of each this release can be found in the [CHANGELOG](CHANGELOG.mdown). 
