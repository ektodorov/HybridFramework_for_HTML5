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

#import <Foundation/Foundation.h>
#import "BridgeListenerHfh.h"

@interface BridgeHelperHfh : NSObject

@property(weak, nonatomic)id<BridgeListenerHfh> bridgeListener;
@property(nonatomic)UIButton *bridgeButton;

/** Gets the instance of the BridgeHelperHfh
 * @param id<BridgeListenerHfh>aListener - Object that comforms to the BridgeListenerHfh Protocol
 * @return (BridgehelperHfh *) - The Singleton instance of BridgehelperHfh
 */
+(BridgeHelperHfh *)getHelperInstance:(id<BridgeListenerHfh>)aListener;

/** Gets the JSON dictionary that was passed with the last call from JavaScript
 * @return (NSDictionary *) - dictionary containing JSON data passed by JavaScript
 */
- (NSDictionary *)getMethodInfo;

/** Gets the JavaScript function name which to be called on orientation change */
- (NSString *)getCallBackForDeviceOrientationChange;

/** Builds string that will be used in the Main VC to call stringByEvaluatingJavaScriptFromString
 * @param (NSString *)aFunctionName - name of the JavaScript function that will be called
 * @param (NSarray *)aArrayArgs - array of NSStrings of the arguments
 * @return (NSString *) - string representation of the JavaScript function, ready to be passed to
 *                      stringByEvaluatingJavaScriptFromString
 */
- (NSString *)buildJsFunction:(NSString *)aFunctionName withArgs:(NSArray *)aArrayArgs;

/** Builds a method call and performs it
 * @param (NSString *)aHfhUriSchemeString - string with HFH URI Scheme. Not URL encoded.
 */
- (void)buildAndInvocateMethod:(NSString *)aHfhUriSchemeString;

/** Performs a call to a JavaScript function in the Main WebView
 * @param (NSString *)aFunctionAndArgs - JavaScript function name and arguments - myFunction(arg, otherArg);
 * @return void
 */
- (void) callJsFunction:(NSString *)aFunctionAndArgs;

/** Performs a call to a JavaScript function in the Main WebView
 * @param (NSString *)aFunc - name of the JavaScript function
 * @param (NSString *)aArg - argument for the JavaScript function
 * @return void
 */
- (void) callJsFunction:(NSString *)aFunc withArg:(NSString *)aArg;

/** Performs a call to a JavaScript function in the Main WebView
 * @param (NSString *)aFunctionName - name of the JavaScript function
 * @param (NSArray *)aArgs - array of objects which would be passed as arguments of the JavaScript function.
 *      The arguments will be passed as strings.
 * @return void
 */
- (void) callJsFunction:(NSString *)aFunctionName withArgs:(NSArray *)aArgs;

/** Perfoms a call to an Objective C method
 * @param (NSURLRequest *)aUrlRequest - HFH URI Scheme passed as a NSURLRequest by JavaScript
 * @return void
 */
- (void) callNativeMethod:(NSURLRequest *)aUrlRequest;

/** Call JavaScipt method. Previously passed as value to HFH_KEY_ONCLICK, for button onclick listener */
- (void) callPerformJavaScript:(id)sender;

/* Instance Variables Persistens */

/** Get an instace variable
 * @param (NSDictionary *)aDict - dictionary containing:
 * HFH_KEY_NAME = "name"
 * HFH_KEY_SUCCESS_CALLBACK = @"success"
 */
- (void) callGetInstanceVariable:(NSDictionary *)aDict;

/** Save an instance variable
 * @param (NSDictionary *)aDict - dictionary containing:
 * HFH_KEY_NAME = "name"
 * HFH_KEY_VALUE = "value"
 * HFH_KEY_SUCCESS_CALLBACK = "success"
 */
- (void) callSaveInstanceVariable:(NSDictionary *)aDict;

/** Remove an instance variable
 * @param (NSDictionary *)aDict - dictionary containing:
 * HFH_KEY_NAME = "name"
 */
- (void) callRemoveInstanceVariable:(NSDictionary *)aDict;


/* Native View use */

/** Set position and size for the main WebView
 * @param (NSDictionary *)aDict - dictionary containing:
 * HFH_KEY_POSX = "x"
 * HFH_KEY_POSY = "y"
 * HFH_KEY_WIDTH = "width"
 * HFH_KEY_HEIGHT = "height"
 */
- (void) callSetSizeWebViewMain:(NSDictionary *)aDict;

/** Make an UIButton
 * @param(NSDictionary *)aDict - dictionary containing:
 *
 * Position:
 * HFH_KEY_POSX = "x"
 * HFH_KEY_POSY = "y"
 *
 * Size:
 * HFH_KEY_WIDTH = "width"
 * HFH_KEY_HEIGHT = "height"
 * 
 * Type (optional):
 * HFH_KEY_BUTTONTYPE = "type"
 *  ButtonTypeCustom = 0
 *  ButtonTypeSystem = 1
 *  ButtonTypeDetailDisclosure = 2
 *  ButtonTypeInfoLight = 3
 *  ButtonTypeInfoDark = 4
 *  ButtonTypeContactAdd = 5
 *  ButtonTypeRoundedRect = 6
 *
 * Color (optional):
 * HFH_KEY_RED = "red"
 * HFH_KEY_GREEN = "green"
 * HFH_KEY_BLUE = "blue";
 * HFH_KEY_ALPHA = "alpha";
 *
 * Background image (optional):
 * HFH_KEY_IMAGE = "img"
 *
 * On click method (optional):
 * HFH_KEY_ONCLICK = "onclick"
 *
 * Title (optional):
 * HFH_KEY_TITLE = "title"
 *
 * AutoresizingMask
 * HFH_KEY_VIEWRESIZINGMASK = "resizingmask";
 *   UIViewAutoresizingNone                 = 0,
 *   UIViewAutoresizingFlexibleLeftMargin   = 1     //1 << 0,
 *   UIViewAutoresizingFlexibleWidth        = 2     //1 << 1,
 *   UIViewAutoresizingFlexibleRightMargin  = 4     //1 << 2,
 *   UIViewAutoresizingFlexibleTopMargin    = 8     //1 << 3,
 *   UIViewAutoresizingFlexibleHeight       = 16    //1 << 4,
 *   UIViewAutoresizingFlexibleBottomMargin = 32    //1 << 5
 *
 * @return index of the view in the array of native views
 */
- (void) callMakeButton:(NSDictionary *)aDict;

/** Set button title
 * @param (NSDictionary *)aDict - dictionary containing:
 * HFH_KEY_VIEWIDX = "viewidx" - index of the view in the array of native views
 * HFH_KEY_TITLE = "title"
 
 */
- (void) setButtonTitle:(NSDictionary *)aDict;

/** Set button background color
 * @param (NSDictionary *)aDict - dictionary containing:
 * HFH_KEY_VIEWIDX = "viewidx" - index of the view in the array of native views
 * HFH_KEY_RED = "red"
 * HFH_KEY_GREEN = "green"
 * HFH_KEY_BLUE = "blue"
 * HFH_KEY_ALPHA = "alpha"
 */
- (void) setBackgroundColor:(NSDictionary *)aDict;

/** Set button background image
 * @param (NSDicitonary *)aDict - dictionary containing:
 * HFH_KEY_VIEWIDX = "viewidx" - index of the view in the array of native views
 * HFH_KEY_IMAGE = "img"
 */
- (void) setButtonBackgroundImage:(NSDictionary *)aDict;

/** Set button frame
 * @param (NSDictionary *)aDict - dictionary containing:
 * Position:
 * HFH_KEY_POSX = "x"
 * HFH_KEY_POSY = "y"
 * Size:
 * HFH_KEY_WIDTH = "width"
 * HFH_KEY_HEIGHT = "height"
 */
- (void) setPositionAndSize:(NSDictionary *)aDict;

/** Set button on click listener
 * @param (NSString *)aDict - dictionary containing:
 * HFH_KEY_VIEWIDX = "viewidx" - index of the view in the array of native views
 * HFH_KEY_ONCLICK = "onclick" - name of a metod that will be called when the button is clicked
 */
- (void) setButtonOnClickListener:(NSDictionary *)aDict;

/** Sets a view's hidden property to ture
 * @param (NSDcitionary *)aDict - dictionary containing:
 * HFH_KEY_VIEWIDX = "viewidx"
 */
- (void) setViewHidden:(NSDictionary *)aDict;

/**  Sets a views hidden property to false
 * @param (NSDictionary *)aDict - dictionary containing:
 * HFH_KEY_VIEWIDX = "viewidx"
 */
- (void) setViewShown:(NSDictionary *)aDict;

/** Remove a view from its parent
 * @param (NSDictionary *)aDict - dictionary containing:
 * HFH_KEY_VIEWIDX = "viewidx" - index of the view in the array of native views
 */
- (void) callRemoveFromSuperView:(NSDictionary *)aDict;

/** Remove a view from the array of native views
 * @param (NSDictionary *)aDict - dictionary containing:
 * HFH_KEY_VIEWIDX = "viewidx" - index of the view in the array of native views
 */
- (void) callReleaseView:(NSDictionary *)aDict;

/** Remove a view from its parent and the array of native views
 * @param (NSDictionary *)aDict - dictionary containing:
 * HFH_KEY_VIEWIDX = "viewidx" - index of the view in the array of native views
 */
- (void) callRemoveView:(NSDictionary *)aDict;


/* Disk storage */

/* Gets path to Documents directory. If there is no value pased for HFH_KEY_DOCSDIR, the path to Temp directory is returned.
 * @param (NSDictionary *)aDict - dictionary containing:
 * HFH_KEY_DOCSDIR = "docs" - ask for path to the docs dir
 */
- (void) callGetPath:(NSDictionary *)aDict;

/** Gets the path to the Documents directory
 * @param (NSDictionary *)aDict - dictionary containing:
 * HFH_KEY_DOCSDIR = "docsdir"
 * HFH_KEY_SUCCESS_CALLBACK = "success"
 */
- (void) callGetPathToDocsDir:(NSDictionary *)aDict;

/** Gets the path to the Temp directory
 * @param (NSDictionary *)aDict - dictionary conatining:
 * HFH_KEY_SUCCESS_CALLBACK = "success"
 */
- (void) callGetPathToTempDir:(NSDictionary *)aDict;

/* File command buffer */
/** Returns a path in to a file named with the passed in the dictionary file name. The file is in the Temp directory.
 * @param (NSDictionary *)aDict - dictionary containing:
 * HFH_BUFFER_FILENAME = "hfh_buffer_name"
 */
- (void) callGetCommandBuffer:(NSDictionary *)aDict;

/** The HFH URI is recorded into a file in the Temp directory, which name is passed with the dictionary
 * @param (NSDictionary *)aDict - dictionary containing:
 * HFH_KEY_BUFFER_FILEPATH = "hfh_bufferfile_path"
 */
- (void) callMethodWithCommandBuffer:(NSDictionary *)aDict;


/* SQLite */
/** Open or create a DB
 * @param (NSDictionary *)aDict - dictionary containing:
 * HFH_KEY_PATH = "path"
 * HFH_KEY_SUCCESS_CALLBACK = "success"
 * HFH_KEY_ERROR_CALLBACK = "error"
 */
- (void) callOpenOrCreateDb:(NSDictionary *)aDict;

/** Open or create a DB using the Docuemnts direcotory as path
 * @param (NSDictionary *)aDict - dictionary containing:
 * HFH_KEY_NAME = "name"
 * HFH_KEY_SUCCESS_CALLBACK = "success"
 * HFH_KEY_ERROR_CALLBACK = "error"
 */
- (void) callOpenOrCreateDbInDocsDir:(NSDictionary *)aDict;

/** Open of create a DB using the Temp directory as path
 * @param (NSDictionary *) - dictionary containing:
 * HFH_KEY_NAME = "name"
 * HFH_KEY_SUCCESS_CALLBACK = "success"
 * HFH_KEY_ERROR_CALLBACK = "error"
 */
- (void) callOpenOrCreateDbInTempDir:(NSDictionary *)aDict;

/** Execute a SQLite statement, that does not return rows
 * @param (NSDictionary *)aDict - dictionary containing:
 * HFH_KEY_SUCCESS_CALLBACK = "success"
 * HFH_KEY_ERROR_CALLBACK = "error"
 * HFH_KEY_SQL = "sql"
 */
- (void) callExecSQL:(NSDictionary *)aDict;

/** Execute a SQLite query, which returns rows
 * @param (NSdictionary *)aDict - dictionary containing:
 * HFH_KEY_SQL = "sql"
 * HFH_KEY_SUCCESS_CALLBACK = "success"
 * HFH_KEY_ERROR_CALLBACK = "error"
 */
- (void) callExecQuery:(NSDictionary *)aDict;

/** Move to next row from the query
 * @param (NSDictionary *)aDict - dictionary containing:
 * HFH_KEY_SUCCESS_CALLBACK = "success"
 * HFH_KEY_ERROR_CALLBACK = "error"
 */
- (void) callMoveToNext:(NSDictionary *)aDict;

/** Close the DB connection
 * @param (NSDictionary *)aDict - dictionary containing:
 * HFH_KEY_SUCCESS_CALLBACK = "success"
 * HFH_KEY_ERROR_CALLBACK = "error"
 */
- (void) callCloseDb:(NSDictionary *)aDict;


/* Camera use (pics, pics in photolibrary, video) */
/** Open native camera app for taking picture/video
 * @param (NSDictionary *)aDict - (dictionary is not used)
 */
- (void) callCamera:(NSDictionary *)aDict;

/** Open native photo library for browsing and selecting picture
 * @param (NSDictionary *)aDict - (dictionary is not used)
 */
- (void) callPhotoLibrary:(NSDictionary *)aDict;

/* Motion Sensor */
/** Register for Device orientation changes. The passed in callback will be called on every orientation change
 * UIDeviceOrientationUnknown = 0
 * UIDeviceOrientationPortrait = 1
 * UIDeviceOrientationPortraitUpsideDown = 2
 * UIDeviceOrientationLandscapeLeft = 3
 * UIDeviceOrientationLandscapeRight = 4
 * UIDeviceOrientationFaceUp = 5
 * UIDeviceOrientationFaceDown = 6
 *
 * UIDeviceOrientationUnknown - The orientation of the device cannot be determined.
 * UIDeviceOrientationPortrait - The device is in portrait mode, with the device held upright and the home button at the bottom.
 * UIDeviceOrientationPortraitUpsideDown - The device is in portrait mode but upside down, with the device held upright and the home button at the top.
 * UIDeviceOrientationLandscapeLeft - The device is in landscape mode, with the device held upright and the home button on the right side.
 * UIDeviceOrientationLandscapeRight - The device is in landscape mode, with the device held upright and the home button on the left side.
 * UIDeviceOrientationFaceUp - The device is held parallel to the ground with the screen facing upwards.
 * UIDeviceOrientationFaceDown - The device is held parallel to the ground with the screen facing downwards.
 *
 * @param (NSDictionary *)aDict - dictionary containing:
 * HFH_KEY_SUCCESS_CALLBACK = "success"
 */
- (void) callStartMonitorDeviceOrientation:(NSDictionary *)aDict;
- (void) callStopMonitorDeviceOrientation:(NSDictionary *)aDict;


/* Contacts */
/** Shows contacts picker
 * @param (NSDictionary *)aDict - (dictionary is not used)
 */
- (void) callShowContacts:(NSDictionary *)aDict;

/* Additional Methods */
- (void) callLoadHome:(NSDictionary *)aDict;
@end
