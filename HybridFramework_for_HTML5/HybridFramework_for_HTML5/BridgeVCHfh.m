/**
 * Copyright (C) <2013>  <Emil Todorov>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>
 */

#import "BridgeVCHfh.h"
#import "ConstantsHfh.h"
#import "BridgeHelperHfh.h"
#import "InstanceDataHfh.h"
#import "MobileCoreServices/UTCoreTypes.h"

#define STRING_EMPTY_HREF @"#"

@interface BridgeVCHfh ()
{
    BridgeHelperHfh *mBridgeHelper;
    UIButton *mMyButton;
    bool mIsButtonAdded;
    ABRecordRef mPersonRef;
}

@property (weak, nonatomic) IBOutlet UIWebView *webViewMain;

@end

@implementation BridgeVCHfh

- (void)viewDidLoad {
    [super viewDidLoad];
	
    mBridgeHelper = [[BridgeHelperHfh alloc] init];
    mBridgeHelper.bridgeListener = self;
    self.webViewMain.scrollView.bounces = false;
    
    NSURL *urlHome = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"wwwroot"]];
    NSURLRequest *req = [NSURLRequest requestWithURL:urlHome];
    [self.webViewMain loadRequest:req];
    
    /* webViewMain should always be at index 0 of the array of native views */
    //NSValue *valueWebView = [NSValue valueWithNonretainedObject:_webViewMain];
    //[[InstanceDataHfh getInstanceData].arrayViews addObject:valueWebView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [InstanceDataHfh releaseInstanceData];
}

#pragma mark WebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = [request URL];
    NSString *strUrl = url.absoluteString;
    if([[strUrl lowercaseString] hasPrefix:HFH_SCHEMA_PREFIX]) {
        __weak BridgeVCHfh* weakSelf = self;
        dispatch_queue_t callHfh = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(callHfh, ^(void){
            BridgeVCHfh* strongSelf = weakSelf;
            if(strongSelf == nil) {return;}
            
            [strongSelf->mBridgeHelper callNativeMethod:request];
        });
        return false;
    }
    if([strUrl hasSuffix:STRING_EMPTY_HREF]) {return false;}
    return true;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    NSLog(@"BridgeVCHfh, %i, webViewDidFinishLoad", __LINE__);
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
//    NSLog(@"BridgeVCHfh, %i, webViewDidStartLoad", __LINE__);
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
//    NSLog(@"BridgeVCHfh, %i, webView:didFailLoadWithError, %@", __LINE__, [error description]);
}

#pragma mark UIImagePickerControllerDelegate Protocol
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:true completion:nil];
    
    NSDictionary *dict = [mBridgeHelper getMethodInfo];
    NSString *fName = [dict objectForKey:HFH_KEY_ERROR_CALLBACK];
    [self callJsFunction:[mBridgeHelper buildJsFunction:fName withArgs:[NSArray arrayWithObject:@"Cancelled"]]];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *img = nil;
        
        if(picker.editing == true) {
            NSLog(@"BridgeVCHfh %i, picker.editing=true", __LINE__);
            //Zoomed or scrolled image if picker.editing = YES;
            img = [info objectForKey:UIImagePickerControllerEditedImage];
        } else {
            NSLog(@"BirdgeVCHfh %i, picker.editing=false", __LINE__);
            img = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        
        //UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);

        /* Save the image to document directory */
        //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
        //NSString *pathDocuments = [paths objectAtIndex:0];
        /* Save to temp dir */
        NSString *tempDirPath = NSTemporaryDirectory();
        NSDate *now = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [dateFormatter setLocale:enUSPOSIXLocale];
        [dateFormatter setDateFormat:@"ddMMyyyy_HHmmss"];
        NSString *strDate = [dateFormatter stringFromDate:now];
        NSString *fileName = [NSString stringWithFormat:@"hfh_%@", strDate];
        
        NSString *pathToFile = [tempDirPath stringByAppendingPathComponent:fileName];
        NSData *dataImage = UIImagePNGRepresentation(img);
        bool writeOK = [dataImage writeToFile:pathToFile atomically:true];
        if(!writeOK) {
            NSString *errorDesc = [NSString stringWithFormat:@"BridgeVCHfh, %i, error saving image to file", __LINE__];
            NSLog(@"%@", errorDesc);
            NSDictionary *dict = [mBridgeHelper getMethodInfo];
            NSString *fName = [dict objectForKey:HFH_KEY_ERROR_CALLBACK];
            [self callJsFunction:[mBridgeHelper buildJsFunction:fName withArgs:[NSArray arrayWithObject:errorDesc]]];
        }
        
        NSDictionary *dict = [mBridgeHelper getMethodInfo];
        NSString *fName = [dict objectForKey:HFH_KEY_SUCCESS_CALLBACK];
        [self callJsFunction:[mBridgeHelper buildJsFunction:fName withArgs:[NSArray arrayWithObject:pathToFile]]];
    }
    
    [picker dismissViewControllerAnimated:true completion:nil];
}

#pragma mark ABPeoplePickerNavigationControllerDelegate Protocol
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    mPersonRef = person;
    
    NSString* name = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString* phone = nil;
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
    if (ABMultiValueGetCount(phoneNumbers) > 0) {
        phone = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
    } else {
        phone = @"NULL";
    }
    
    NSString *strRet = [NSString stringWithFormat:@"%@:%@", name, phone];
    NSDictionary *dict = [mBridgeHelper getMethodInfo];
    NSString *fName = [dict objectForKey:HFH_KEY_SUCCESS_CALLBACK];
    [self callJsFunction:[mBridgeHelper buildJsFunction:fName withArgs:[NSArray arrayWithObject:strRet]]];
    
    [self dismissViewControllerAnimated:true completion:nil];
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier {
    return NO;
}

#pragma mark BirdgeListener Protocol
- (void)callJsFunction:(NSString *)aFunctionAndArgs {
   [self.webViewMain stringByEvaluatingJavaScriptFromString:aFunctionAndArgs];
}

- (void)callAddSubView:(UIView *)aView {
    [self.view addSubview:aView];
}

- (UIWebView *) getWebViewMain {
    return self.webViewMain;
}

- (void)callShowCamera {
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePicker animated:YES completion:nil];
    } else {
        NSString *strRet = [NSString stringWithFormat:@"BridgeVCHfh, %i, camera not available", __LINE__];
        NSLog(@"%@", strRet);
        NSDictionary *dict = [mBridgeHelper getMethodInfo];
        NSString *fName = [dict objectForKey:HFH_KEY_ERROR_CALLBACK];
        [self callJsFunction:[mBridgeHelper buildJsFunction:fName withArgs:[NSArray arrayWithObject:strRet]]];
    }
}

- (void)callShowPhotoLibrary {
    NSLog(@"BridgeVCHfh, %i, callShowPhotoLibrary", __LINE__);
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePicker animated:YES completion:nil];
    } else {
        NSString *strRet = [NSString stringWithFormat:@"BridgeVCHfh, %i, photo library not available", __LINE__];
        NSLog(@"%@", strRet);
        NSDictionary *dict = [mBridgeHelper getMethodInfo];
        NSString *fName = [dict objectForKey:HFH_KEY_ERROR_CALLBACK];
        [self callJsFunction:[mBridgeHelper buildJsFunction:fName withArgs:[NSArray arrayWithObject:strRet]]];
    }
}

- (void)callShowAddressBook {
    ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    peoplePicker.peoplePickerDelegate = self;
    [self presentViewController:peoplePicker animated:true completion:nil];
}

- (void)callBeginDeviceOrientationNotif {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)callEndDeviceOrientationNotif {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (void)orientationChanged:(NSNotification *)notification {
    UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation]; //int UIDeviceOrientation is enum
    NSString *fName = [mBridgeHelper getCallBackForDeviceOrientationChange];
    [mBridgeHelper buildJsFunction:fName withArgs:[NSArray arrayWithObject:[NSString stringWithFormat:@"%li", (long)currentOrientation]]];
}

@end
