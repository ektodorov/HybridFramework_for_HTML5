HybridFramework_for_HTML5

HybridFramework_for_HTML5 is a little framework that enables you to write applications with HTML, CSS, JavaScript and package them as native iOS applications. You can write your web application using all the APIs available for web applications running in Mobile Safari and more.
The framework throught its API enables you to:
- use native view
- use disk storage (as native apps do)
- use SQLite (as native apps do)
- use device specific hardware (camer, address book)
- preserve state while using multiple HTML pages



Integration with PhoneGap
If you are familiar and used to working with PhoneGap you don't have to make decision between PhoneGap and HybridFramework_for_HMTL5. You can use HybridFramework_for_HTML5 with PhoneGap.
To do so you need to:

Create a New Group in the project and add the files:
BridgeHelpreHfh.h
BridgeHelperHfh.m
BridgeListenerHfh.h
DatabaseHfh.h
DatabaseHfh.m
ConstantsHfh.h
ConstantsHfh.m

Import the ConstantsHfh.h, BridgeHelperHfh.h file in the "CDVViewController.m" file.
In "CDVViewController.m" file add the methods from BridgeVCHfh.m file from the mark:
#pragma mark BirdgeListener Protocol


Add the following lines in the "CDVViewController.m" file:

1.Import BridgeHelperhHfh header file:

	#import "BridgeHelperHfh.h"


2.Declare mBridgeHelper instance varialbe:

	BridgeHelperHfh *mBridgeHelper;


3.In the "__init" method create mBridgeHelper:

	mBridgeHelper = [[BridgeHelperHfh alloc] init];


4.In the "__init" method set listener for mBridgeHelper to self:

    mBridgeHelper.bridgeListener = self;



5.In the webView:shouldStartLoadWithRequest:navigationType method of the UIWebViewDelegate protocol add a case to handle
HFH URI Scheme

	else if ([[url sheme] isEqualToString:@"jn"]) {
		dispatch_queue_t callHfh = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    	dispatch_async(callHfh, ^(void){
   			[mBridgeHelper callNativeMethod:request];
  	  	});
    	return false;
	}



