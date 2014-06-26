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

#import "BridgeHelperHfh.h"
#import "ConstantsHfh.h"
#import "objc/message.h"
#import "InstanceDataHfh.h"
#import "DatabaseHfh.h"

@interface BridgeHelperHfh()
{
    DatabaseHfh *mDb;
    NSDictionary *mDictMethodInfo;
    NSString *mStrCallBackForDeviceOrientationChange;
}

- (void)getRowDataAsJsonString:(DatabaseHfh *)aDb resultCode:(int)aCode methodDict:(NSDictionary *)aDict;

@end

@implementation BridgeHelperHfh

static BridgeHelperHfh *helperInstance;

+ (BridgeHelperHfh *) getHelperInstance:(id<BridgeListenerHfh>)aListener {
    if(helperInstance == nil) {
        @synchronized(self) {
            if(helperInstance == nil) {
                helperInstance = [[BridgeHelperHfh alloc] init];
            }
        }
    }
    helperInstance.bridgeListener = aListener;
    return helperInstance;
}

- (NSDictionary *) getMethodInfo {
    return mDictMethodInfo;
}

- (NSString *)getCallBackForDeviceOrientationChange {
    return mStrCallBackForDeviceOrientationChange;
}

- (void) callJsFunction:(NSString *)aFunctionAndArgs {
    __weak BridgeHelperHfh *ctx = self;
    dispatch_async(dispatch_get_main_queue(), ^{ [ctx.bridgeListener callJsFunction:aFunctionAndArgs]; });
}

- (void) callJsFunction:(NSString *)aFunc withArg:(NSString *)aArg {
    if(aArg == nil) { aArg = @""; }
    NSString *funcAndArgs = [NSString stringWithFormat:@"%@('%@')", aFunc, aArg];
    __weak BridgeHelperHfh *ctx = self;
    dispatch_async(dispatch_get_main_queue(), ^{ [ctx.bridgeListener callJsFunction:funcAndArgs]; });
}

- (void) callJsFunction:(NSString *)aFunctionName withArgs:(NSArray *)aArgs {
    NSMutableString *jsFunction = [NSMutableString stringWithFormat:@"%@([", aFunctionName];
    int arrayCount = [aArgs count];
    int arrayCountForLoop = [aArgs count];
    for(int x = 0; x < arrayCountForLoop; x++) {
        [jsFunction appendFormat:@"'%@'", [aArgs objectAtIndex:x]];
        arrayCount--;
        if(arrayCount > 0) {
            [jsFunction appendString:@", "];
        } else {
            [jsFunction appendString:@"]);"];
        }
    }
    __weak BridgeHelperHfh *ctx = self;
    //NSLog(@"BridgeHelperHfh, %i, jsFunction=%@", __LINE__, jsFunction);
    dispatch_async(dispatch_get_main_queue(), ^{ [ctx.bridgeListener callJsFunction:jsFunction]; });
}

- (void) callNativeMethod:(NSURLRequest *)aUrlRequest {
    NSURL *url = [aUrlRequest URL];
    NSString *strUrl = [url.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    strUrl = [strUrl substringFromIndex:HFH_SCHEMA_PREFIX.length];
    //NSLog(@"BridgehelperHfh, %i, strUrl=%@, str.length=%i", __LINE__, strUrl, [strUrl length]);
    
    NSError *errorJson;
    mDictMethodInfo = [NSJSONSerialization JSONObjectWithData:[strUrl dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&errorJson];
    if(errorJson != nil) {
        NSLog(@"BridgeVCHfh %d, callNativeMethod, error parsing JSON from string:%@, error description-%@", __LINE__, strUrl, [errorJson description]);
        return;
    }
    
    NSString *methodName = [mDictMethodInfo objectForKey:HFH_KEY_METHODNAME];
    
    if(methodName == nil) {
        NSLog(@"BridgeVCHfh %i, missing methodname from string:%@", __LINE__, strUrl);
        NSString *str = [NSString stringWithFormat:@"BridgeHelperHfh, %s, %i, Missing method name from string-%@", __FUNCTION__, __LINE__, strUrl];
        NSString *fName = [mDictMethodInfo objectForKey:HFH_KEY_ERROR_CALLBACK];
        [self callJsFunction:fName withArg:str];
        return;
    }
    
    SEL nativeMethod = NSSelectorFromString(methodName);
    if([self respondsToSelector:nativeMethod]) {
        void (*pFunc)(id, SEL, NSDictionary *);
        pFunc = (void (*)(id, SEL, NSDictionary *)) [self methodForSelector:nativeMethod];
        pFunc(self, nativeMethod, mDictMethodInfo);
    } else {
        NSLog(@"BridgeHelperHfh, %i, calling not implemented Objective C method - %@", __LINE__, methodName);
        NSString *str = [NSString stringWithFormat:@"BridgeHelperHfh, %s, %i, Calling not implemented Objective C method-%@", __FUNCTION__, __LINE__, methodName];
        
        NSString *fName = [mDictMethodInfo objectForKey:HFH_KEY_ERROR_CALLBACK];
        [self callJsFunction:fName withArg:str];
    }
}

- (void) callPerformJavaScript:(id)sender {
    NSUInteger idx = [[InstanceDataHfh getInstanceData].arrayViews indexOfObject:sender];
    //NSLog(@"BridgeHelperHfh, %i, idx=%i", __LINE__, idx);
    NSString *strJavaScript = [[InstanceDataHfh getInstanceData].arrayPerformJavaScript objectAtIndex:idx];
    //NSLog(@"BirdgeHelperHfh, %i, strJavaScript=%@", __LINE__, strJavaScript);
    __weak BridgeHelperHfh *ctx = self;
    dispatch_async(dispatch_get_main_queue(), ^{ [ctx.bridgeListener callJsFunction:strJavaScript]; });
}

/* Instance Variables Persistence */
//'jn://{"method":"callGetInstanceVariable:", "name":"my_var_name", "success":"callback_function_name", "error":"callback_function_name"}'
- (void) callGetInstanceVariable:(NSDictionary *)aDict {
    NSString *val = [[InstanceDataHfh getInstanceData].dictInstanceVaribles objectForKey:[aDict objectForKey:HFH_KEY_NAME]];
    if(val != nil) {
        NSString *fName = [aDict objectForKey:HFH_KEY_SUCCESS_CALLBACK];
        [self callJsFunction:fName withArg:val];
    } else {
        NSString *fName = [aDict objectForKey:HFH_KEY_ERROR_CALLBACK];
        [self callJsFunction:fName withArg:@""];
    }
}

//'jn://{"method":"callSaveInstanceVariable:", "name":"my_var_name", "value":"var_value", "success":"callback_function_name", "error":"callback_function_name"}'
- (void) callSaveInstanceVariable:(NSDictionary *)aDict {
    NSString *valName = [aDict objectForKey:HFH_KEY_NAME];
    NSString *val = [aDict objectForKey:HFH_KEY_VALUE];
    //NSLog(@"BridgeHelperHfh, %i, valName=%@, val=%@", __LINE__, valName, val);
    [[InstanceDataHfh getInstanceData].dictInstanceVaribles setObject:val forKey:valName];
    NSString *fName = [aDict objectForKey:HFH_KEY_SUCCESS_CALLBACK];
    [self callJsFunction:fName withArg:@""];
}

//'jn://{"method":"callRemoveInstanceVariable:", "name":"my_var_name"}'
- (void) callRemoveInstanceVariable:(NSDictionary *)aDict {
    NSString *valName = [aDict objectForKey:HFH_KEY_NAME];
    [[InstanceDataHfh getInstanceData].dictInstanceVaribles removeObjectForKey:valName];
}


/* Native View use */
//'jn://{"method":"callSetSizeWebViewMain:", "x":x_position, "y":y_position, "width":size_width, "height":size_height}'
- (void) callSetSizeWebViewMain:(NSDictionary *)aDict {
    __weak UIWebView *webViewMain = [self.bridgeListener getWebViewMain];
    //NSValue *valWebView = [[InstanceDataHfh getInstanceData].arrayViews firstObject];
    //UIWebView *webViewMainn = (UIWebView *)[valWebView nonretainedObjectValue];
    int posX = [(NSNumber *)[aDict objectForKey:HFH_KEY_POSX] intValue];
    int posY = [(NSNumber *)[aDict objectForKey:HFH_KEY_POSY] intValue];
    int width = [(NSNumber *)[aDict objectForKey:HFH_KEY_WIDTH] intValue];
    int height = [(NSNumber *)[aDict objectForKey:HFH_KEY_HEIGHT] intValue];
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        webViewMain.frame = CGRectMake(posX, posY, width, height);
    });
}

//'jn://{"method":callMakeButton:", "buttontype":type_int, "red":redcolorvalue, "green":greencolorvalue, "blue":bluecolorvalue, "alpha":alpha_value, "x":x_position, "y":y_position,
//    "width":size_width, "height":size_height, "onclick":"javascript_function_name", "title":"button_title", "resizingmask":resizingmask_value}'
// Values for color - [0-255]
- (void) callMakeButton:(NSDictionary *)aDict {
    NSNumber *numButtonType = [aDict objectForKey:HFH_KEY_BUTTONTYPE];
    UIButton *myButton = [UIButton buttonWithType:[numButtonType intValue]];
    [myButton setBackgroundColor:[UIColor grayColor]];
    
    if([aDict objectForKey:HFH_KEY_RED]) {
        int red = [(NSNumber *)[aDict objectForKey:HFH_KEY_RED] intValue];
        int green = [(NSNumber *)[aDict objectForKey:HFH_KEY_GREEN] intValue];
        int blue = [(NSNumber *)[aDict objectForKey:HFH_KEY_BLUE] intValue];
        int alpha = [(NSNumber *)[aDict objectForKey:HFH_KEY_ALPHA] intValue];
        [myButton setBackgroundColor:[UIColor colorWithRed:1.0f/red green:1.0f/green blue:1.0f/blue alpha:1.0f/alpha]];
    }
    
    NSString *strImg = (NSString *)[aDict objectForKey:HFH_KEY_IMAGE];
    if(strImg) {[myButton setBackgroundImage:[UIImage imageNamed:strImg] forState:UIControlStateNormal];}
    
    int posX = [(NSNumber *)[aDict objectForKey:HFH_KEY_POSX] intValue];
    int posY = [(NSNumber *)[aDict objectForKey:HFH_KEY_POSY] intValue];
    int width = [(NSNumber *)[aDict objectForKey:HFH_KEY_WIDTH] intValue];
    int height = [(NSNumber *)[aDict objectForKey:HFH_KEY_HEIGHT] intValue];
    myButton.frame = CGRectMake(posX, posY, width, height);
    myButton.autoresizingMask = [(NSNumber *)[aDict objectForKey:HFH_KEY_VIEWRESIZINGMASK] intValue];
    
    NSString *strTitle = (NSString *)[aDict objectForKey:HFH_KEY_TITLE];
    //__weak UIButton *weakButton = myButton;
    __weak BridgeHelperHfh *ctx = self;
    dispatch_async(dispatch_get_main_queue(), ^(void){
        if(strTitle) {[myButton setTitle:strTitle forState:UIControlStateNormal];}
        [ctx.bridgeListener callAddSubView:myButton];
    });
    
    [[InstanceDataHfh getInstanceData].arrayViews addObject:myButton];
    int idx = [[InstanceDataHfh getInstanceData].arrayViews count];
    idx--;
	
	NSString *strOnClick = (NSString *)[aDict objectForKey:HFH_KEY_ONCLICK];
    if(strOnClick) {
		if(idx >= [[InstanceDataHfh getInstanceData].arrayPerformJavaScript count]) {
			for(int x = 0; x <= idx; x++) {
				[[InstanceDataHfh getInstanceData].arrayPerformJavaScript addObject:[NSNull null]];
			}
		}
		[[InstanceDataHfh getInstanceData].arrayPerformJavaScript removeObjectAtIndex:idx];
		[[InstanceDataHfh getInstanceData].arrayPerformJavaScript insertObject:strOnClick atIndex:idx];
        //[[InstanceDataHfh getInstanceData].arrayPerformJavaScript addObject:strOnClick];
        [myButton addTarget:self action:@selector(callPerformJavaScript:) forControlEvents:UIControlEventTouchUpInside];
    }

    NSString *fName = [aDict objectForKey:HFH_KEY_SUCCESS_CALLBACK];
    [self callJsFunction:fName withArg:[NSString stringWithFormat:@"%i", idx]];
}

//'jn://{"method":"setButtonTitle:", "title":"button_title", "viewidx":index_in_the_instance_views_array}'
- (void) setButtonTitle:(NSDictionary *)aDict {
    NSString *strTitle = (NSString *)[aDict objectForKey:HFH_KEY_TITLE];
    NSNumber *viewIdx = [aDict objectForKey:HFH_KEY_VIEWIDX];
    __weak UIButton *view = (UIButton *)[[InstanceDataHfh getInstanceData].arrayViews objectAtIndex:[viewIdx intValue]];
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [view setTitle:strTitle forState:UIControlStateNormal];
    });
}

//'jn://{"method":"setBackgroundColor:", "red":color_value, "green":color_value, "blue":color_value, "alpha":alpha_value, "viewidx":index_in_the_instance_views_array}'
- (void) setBackgroundColor:(NSDictionary *)aDict {
    int red = [(NSNumber *)[aDict objectForKey:HFH_KEY_RED] intValue];
    int green = [(NSNumber *)[aDict objectForKey:HFH_KEY_GREEN] intValue];
    int blue = [(NSNumber *)[aDict objectForKey:HFH_KEY_BLUE] intValue];
    int alpha = [(NSNumber *)[aDict objectForKey:HFH_KEY_ALPHA] intValue];
    
    NSNumber *viewIdx = [aDict objectForKey:HFH_KEY_VIEWIDX];
    UIView *view = (UIView *)[[InstanceDataHfh getInstanceData].arrayViews objectAtIndex:[viewIdx intValue]];
    [view setBackgroundColor:[UIColor colorWithRed:red green:green blue:blue alpha:alpha]];
}

//'jn://{"method":"setButtonBackgroundImage:", "img":"filepath_toimage_file", "viewidx":index_in_the_instance_views_array}'
- (void) setButtonBackgroundImage:(NSDictionary *)aDict {
    NSString *strImg = (NSString *)[aDict objectForKey:HFH_KEY_IMAGE];
    UIImage *img = [UIImage imageNamed:strImg];
    
    NSNumber *viewIdx = [aDict objectForKey:HFH_KEY_VIEWIDX];
    UIButton *view = (UIButton *)[[InstanceDataHfh getInstanceData].arrayViews objectAtIndex:[viewIdx intValue]];
    [view setBackgroundImage:img forState:UIControlStateNormal];
}

//'jn://{"method":"setPositionAndSize:", "x":x_position, "y":y_position, "width":size_width, "height":size_height, "viewidx":index_in_the_instance_views_array}'
- (void) setPositionAndSize:(NSDictionary *)aDict {
    int posX = [(NSNumber *)[aDict objectForKey:HFH_KEY_POSX] intValue];
    int posY = [(NSNumber *)[aDict objectForKey:HFH_KEY_POSY] intValue];
    int width = [(NSNumber *)[aDict objectForKey:HFH_KEY_WIDTH] intValue];
    int height = [(NSNumber *)[aDict objectForKey:HFH_KEY_HEIGHT] intValue];
    
    NSNumber *viewIdx = [aDict objectForKey:HFH_KEY_VIEWIDX];
    UIView *view = (UIView *)[[InstanceDataHfh getInstanceData].arrayViews objectAtIndex:[viewIdx intValue]];
    view.frame = CGRectMake(posX, posY, width, height);
}

//'jn://{"method":"setButtonOnClickListener:", "onclick":"javascript_function_name", "viewidx":index_in_the_instance_views_array}'
- (void) setButtonOnClickListener:(NSDictionary *)aDict {
    NSString *strOnClick = (NSString *)[aDict objectForKey:HFH_KEY_ONCLICK];
    //[[InstanceDataHfh getInstanceData].arrayPerformJavaScript addObject:strOnClick];
    NSNumber *viewIdx = [aDict objectForKey:HFH_KEY_VIEWIDX];
    UIButton *view = (UIButton *)[[InstanceDataHfh getInstanceData].arrayViews objectAtIndex:[viewIdx intValue]];
	
	if([viewIdx intValue] >= [[InstanceDataHfh getInstanceData].arrayPerformJavaScript count]) {
		for(int x = 0; x <= [viewIdx intValue]; x++) {
			[[InstanceDataHfh getInstanceData].arrayPerformJavaScript addObject:[NSNull null]];
		}
	}
	[[InstanceDataHfh getInstanceData].arrayPerformJavaScript removeObjectAtIndex:[viewIdx intValue]];
	[[InstanceDataHfh getInstanceData].arrayPerformJavaScript insertObject:strOnClick atIndex:[viewIdx intValue]];

    [view addTarget:self action:@selector(callPerformJavaScript:) forControlEvents:UIControlEventTouchUpInside];
}

//'jn://{"method":"setViewHidden:", "viewidx":index_in_the_instance_views_array}'
- (void) setViewHidden:(NSDictionary *)aDict {
    NSNumber *viewIdx = [aDict objectForKey:HFH_KEY_VIEWIDX];
    __weak UIView *view = (UIView *)[[InstanceDataHfh getInstanceData].arrayViews objectAtIndex:[viewIdx intValue]];
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [view setHidden:true];
    });
}

//'jn://{"method":"setViewShown:", "viewidx":index_in_the_instance_views_array}'
- (void) setViewShown:(NSDictionary *)aDict {
    NSNumber *viewIdx = [aDict objectForKey:HFH_KEY_VIEWIDX];
    __weak UIView *view = (UIView *)[[InstanceDataHfh getInstanceData].arrayViews objectAtIndex:[viewIdx intValue]];
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [view setHidden:false];
    });
}

//'jn://{"method":"callRemoveFromSuperView:", "viewidx":index_in_the_instance_views_array}'
- (void) callRemoveFromSuperView:(NSDictionary *)aDict {
    NSNumber *viewIdx = [aDict objectForKey:HFH_KEY_VIEWIDX];
    __weak UIView *view = (UIView *)[[InstanceDataHfh getInstanceData].arrayViews objectAtIndex:[viewIdx intValue]];
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [view removeFromSuperview];
    });
}

//'jn://{"method":"callReleaseView:", "viewidx":index_in_the_instance_views_array}'
- (void) callReleaseView:(NSDictionary *)aDict {
    NSNumber *viewIdx = [aDict objectForKey:HFH_KEY_VIEWIDX];
    [[InstanceDataHfh getInstanceData].arrayViews removeObjectAtIndex:[viewIdx intValue]];
    [[InstanceDataHfh getInstanceData].arrayPerformJavaScript removeObjectAtIndex:[viewIdx integerValue]];
}

//'jn://{"method":"callRemoveView:", "viewidx":index_in_the_instance_views_array}'
- (void) callRemoveView:(NSDictionary *)aDict {
    NSNumber *viewIdx = [aDict objectForKey:HFH_KEY_VIEWIDX];
    NSInteger idx = [viewIdx integerValue];
    __weak UIView *view = (UIView *)[[InstanceDataHfh getInstanceData].arrayViews objectAtIndex:idx];
    [[InstanceDataHfh getInstanceData].arrayViews removeObjectAtIndex:idx]; //safe, the view is still attached to the super view won't be released until removed from super view
    [[InstanceDataHfh getInstanceData].arrayPerformJavaScript removeObjectAtIndex:idx];
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [view removeFromSuperview];
    });
}


/* Disk storage */
//'jn://{"method":"callGetPath:", "docsdir":"yes", "success":"callback_function_name"}'
//callback should expect the path to be passed as a string argument
//if key docsdir exists with some value the path to docsdir will be returned, if it does not exist, path temp dir will be returned.
- (void) callGetPath:(NSDictionary *)aDict {
    NSString *retPath = nil;
    NSString *path = [aDict objectForKey:HFH_KEY_DOCSDIR];
    if(path != nil) {
        NSArray *pathsDocs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
        retPath = [pathsDocs lastObject];
    } else {
        retPath = NSTemporaryDirectory();
    }
    NSString *fName = [aDict objectForKey:HFH_KEY_SUCCESS_CALLBACK];
    [self callJsFunction:fName withArg:retPath];
}

//'jn://{"method":"callGetPathToDocsDir:", "success":"callback_function_name"}'
//callback should expect the path to be passed as a string argument
- (void) callGetPathToDocsDir:(NSDictionary *)aDict {
    NSArray *pathsDocs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
    NSString *retPath = [pathsDocs lastObject];
    NSString *fName = [aDict objectForKey:HFH_KEY_SUCCESS_CALLBACK];
    [self callJsFunction:fName withArg:retPath];
}

//'jn://{"method":"callGetPathToTempDir:", "success":"callback_function_name"}'
//callback should expect the path to be passed as a string argument
- (void) callGetPathToTempDir:(NSDictionary *)aDict {
    NSString *retPath = NSTemporaryDirectory();
    NSString *fName = [aDict objectForKey:HFH_KEY_SUCCESS_CALLBACK];
    [self callJsFunction:fName withArg:retPath];
}

/* File command buffer */
//'jn://{"method":"callGetCommandBuffer:", "success":"callback_function_name"}'
//callback should expect the path to command buffer file to be passed as argument
- (void) callGetCommandBuffer:(NSDictionary *)aDict {
    NSString *bufPath = NSTemporaryDirectory();
    NSString *bufFilePath = [bufPath stringByAppendingPathComponent:HFH_BUFFER_FILENAME];
    NSString *fName = [aDict objectForKey:HFH_KEY_SUCCESS_CALLBACK];
    [self callJsFunction:fName withArg:bufFilePath];
}

//'jn://{"method":"callMethodWithCommandBuffer:", "hfh_bufferfile_path":"filepath_to_bufferfile", "error":"callback_function_name"}'
//callback should expect error description to be passed as string argument
- (void) callMethodWithCommandBuffer:(NSDictionary *)aDict {
    NSString *bufFilePath = [aDict objectForKey:HFH_KEY_BUFFER_FILEPATH];
    NSError *err;
    NSString *strCommand = [NSString stringWithContentsOfFile:bufFilePath encoding:NSUTF8StringEncoding error:&err];
    if(err) {
        NSLog(@"BridgeHelperHfh, %i, error reading file - %@", __LINE__, bufFilePath);
        NSString *callBack = [aDict objectForKey:HFH_KEY_ERROR_CALLBACK];
        if(callBack != nil) {
            NSString *str = [NSString stringWithFormat:@"BridgeHelperHfh, %i, %s, error reading file - %@", __LINE__, __FUNCTION__, bufFilePath];
            [self callJsFunction:callBack withArg:str];
        }
    } else {
        [self buildAndInvocateMethod:strCommand];
    }
    
}

/* SQLite */
//'jn://{"method":"callOpenOrCreateDb:", "path":"file_path_to_dbfile", "success":"callback_function_name", "error":"callback_function_name"}'
- (void) callOpenOrCreateDb:(NSDictionary *)aDict {
    NSString *dbPath = [aDict objectForKey:HFH_KEY_PATH];
    if(mDb == nil) {mDb = [[DatabaseHfh alloc] init];}
    NSString *fName = nil;
    if([mDb openOrCreate:dbPath]) {
        fName = [aDict objectForKey:HFH_KEY_SUCCESS_CALLBACK];
    } else {
        fName = [aDict objectForKey:HFH_KEY_ERROR_CALLBACK];
    }
    [self callJsFunction:fName withArg:@""];
}

//'jn://{"method":"callOpenOrCreateDbInDocsDir:", "name":"db_file_name", "success":"callback_function_name", "error":"callback_function_name"}'
- (void) callOpenOrCreateDbInDocsDir:(NSDictionary *)aDict {
    NSArray *pathsDocs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
    NSString *path = [pathsDocs lastObject];
    NSString *dbPath = [path stringByAppendingPathComponent:[aDict objectForKey:HFH_KEY_NAME]];
    
    if(mDb == nil) {mDb = [[DatabaseHfh alloc] init];}
    NSString *fName = nil;
    if([mDb openOrCreate:dbPath]) {
        fName = [aDict objectForKey:HFH_KEY_SUCCESS_CALLBACK];
    } else {
        fName = [aDict objectForKey:HFH_KEY_ERROR_CALLBACK];
    }
    [self callJsFunction:fName withArg:@""];
}

//'jn://{"method":"callOpenOrCreateDbInTempDir:", "name":"db_file_name", "success":"callback_function_name", "error":"callback_function_name"}'
- (void) callOpenOrCreateDbInTempDir:(NSDictionary *)aDict {
    NSString *pathTemp = NSTemporaryDirectory();
    NSString *dbPath = [pathTemp stringByAppendingPathComponent:[aDict objectForKey:HFH_KEY_NAME]];
    
    if(mDb == nil) {mDb = [[DatabaseHfh alloc] init];}
    NSString *fName = nil;
    if([mDb openOrCreate:dbPath]) {
        fName = [aDict objectForKey:HFH_KEY_SUCCESS_CALLBACK];
    } else {
        fName = [aDict objectForKey:HFH_KEY_ERROR_CALLBACK];
    }
    [self callJsFunction:fName withArg:@""];
}

//'jn://{"method":"callExecSQL:", "sql":"sqlite_statement", "success":"callback_function_name", "error":"callback_function_name"}'
- (void) callExecSQL:(NSDictionary *)aDict {
    NSString *stmt = [aDict objectForKey:HFH_KEY_SQL];
    if(mDb == nil) {
        NSString *fName = [aDict objectForKey:HFH_KEY_ERROR_CALLBACK];
        NSString *msg = [NSString stringWithFormat:@"BridgeHelperHfh, %i, %s, error-there is no database openned", __LINE__, __FUNCTION__];
        [self callJsFunction:fName withArg:msg];
        return;
    }
    NSString *fName = nil;
    if([mDb execSQLite:stmt]) {
        fName = [aDict objectForKey:HFH_KEY_SUCCESS_CALLBACK];
    } else {
        fName = [aDict objectForKey:HFH_KEY_ERROR_CALLBACK];
    }
    [self callJsFunction:fName withArg:@""];
}

//'jn://{"method":"callExecQuery:", "sql":"sqlite_query_statment", "success":"callback_function_name", "error":"callback_function_name"}'
- (void) callExecQuery:(NSDictionary *)aDict {
    NSString *query = [aDict objectForKey:HFH_KEY_SQL];
    if(mDb == nil) {
        NSString *fName = [aDict objectForKey:HFH_KEY_ERROR_CALLBACK];
        NSString *msg = [NSString stringWithFormat:@"BridgeHelperHfh, %i, %s, error-there is no database openned", __LINE__, __FUNCTION__];
        [self callJsFunction:fName withArg:msg];
        return;
    }
    int retVal = [mDb execQuery:query];
    [self getRowDataAsJsonString:mDb resultCode:retVal methodDict:aDict];
}

//'jn://{"method":"callMoveToNext:", "success":"callback_function_name", "error":"callback_function_name"}'
- (void) callMoveToNext:(NSDictionary *)aDict {
    int retVal = [mDb moveToNext];
    [self getRowDataAsJsonString:mDb resultCode:retVal methodDict:aDict];
}

//'jn://{"method":"callCloseDb:", "success":"callback_function_name", "error":"callback_function_name"}'
- (void) callCloseDb:(NSDictionary *)aDict {
    NSString *fName = nil;
    if([mDb closeDb]) {
        fName = [aDict objectForKey:HFH_KEY_SUCCESS_CALLBACK];
    } else {
        fName = [aDict objectForKey:HFH_KEY_ERROR_CALLBACK];
    }
    [self callJsFunction:fName withArg:@""];
}


/* Camera use (pics, pics in photolibrary, video) */

//'jn://{"method":"callCamera:"}'
- (void) callCamera:(NSDictionary *)aDict {
    __weak BridgeHelperHfh *ctx = self;
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [ctx.bridgeListener callShowCamera];
    });
}

//'jn://{"method":"callPhotoLibrary:", "success":"callback_function_name"}'
- (void) callPhotoLibrary:(NSDictionary *)aDict {
    __weak BridgeHelperHfh *ctx = self;
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [ctx.bridgeListener callShowPhotoLibrary];
    });
}


/* Motion Sensor */

//'jn://{"method":"callStartMonitorDeviceOrientation:", "success":"callback_function_name"}'
- (void) callStartMonitorDeviceOrientation:(NSDictionary *)aDict {
    mStrCallBackForDeviceOrientationChange = [aDict objectForKey:HFH_KEY_SUCCESS_CALLBACK];
    __weak BridgeHelperHfh *ctx = self;
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [ctx.bridgeListener callBeginDeviceOrientationNotif];
    });
}

//'jn://{"method":"callStopMonitorDeviceOrientation:"}'
- (void) callStopMonitorDeviceOrientation:(NSDictionary *)aDict {
    __weak BridgeHelperHfh *ctx = self;
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [ctx.bridgeListener callEndDeviceOrientationNotif];
    });
    mStrCallBackForDeviceOrientationChange = nil;
}


/* Contacts */

//'jn://{"method":"callShowContacts:", "success":"callback_function_name"}'
- (void) callShowContacts:(NSDictionary *)aDict {
    __weak BridgeHelperHfh *ctx = self;
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [ctx.bridgeListener callShowAddressBook];
    });
}

#pragma mark Util methods
- (NSString *) buildJsFunction:(NSString *)aFunctionName withArgs:(NSArray *)aArrayArgs {
    NSMutableString *jsFunc = [NSMutableString stringWithFormat:@"%@('", aFunctionName];
    int arrayCount = [aArrayArgs count];
    for(int x = 0; x < arrayCount; x++) {
        [jsFunc appendString:[aArrayArgs objectAtIndex:x]];
        if((x + 1) < arrayCount) {[jsFunc appendString:@", "];}
    }
    [jsFunc appendString:@"');"];
    return jsFunc;
}

- (void)getRowDataAsJsonString:(DatabaseHfh *)aDb resultCode:(int)aCode methodDict:(NSDictionary *)aDict {
    NSString *fName = nil;
    if(aCode == SQLITE_ROW) {
        fName = [aDict objectForKey:HFH_KEY_SUCCESS_CALLBACK];
        int cols = [mDb getColumnCount];
        NSMutableDictionary *dictRow = [[NSMutableDictionary alloc] init];
        for(int x = 0; x < cols; x++) {
            NSString *colName = [mDb getColumnName:x];
            NSString *colVal = [mDb getTextColumn:x];
            [dictRow setObject:colVal forKey:colName];
        }
        NSError *err;
        NSString *strRow = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dictRow options:0 error:&err] encoding:NSUTF8StringEncoding];
        [self callJsFunction:fName withArg:strRow];
    } else if(aCode == SQLITE_DONE) {
        fName = [aDict objectForKey:HFH_KEY_SUCCESS_CALLBACK];
        [self callJsFunction:fName withArg:@"SQLITE_DONE"];
    } else {
        fName = [aDict objectForKey:HFH_KEY_ERROR_CALLBACK];
        [self callJsFunction:fName withArg:@""];
    }
}

- (void)buildAndInvocateMethod:(NSString *)aHfhUriSchemeString {
    NSString *strUrl = [aHfhUriSchemeString substringFromIndex:HFH_SCHEMA_PREFIX.length];
    //NSLog(@"BridgehelperHfh, %i, strUrl=%@", __LINE__, strUrl);
    
    NSError *errorJson;
    mDictMethodInfo = [NSJSONSerialization JSONObjectWithData:[strUrl dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&errorJson];
    if(errorJson != nil) {
        NSLog(@"BridgeVCHfh %d, callNativeMethod, error parsing JSON from string:%@, error description-%@", __LINE__, strUrl, [errorJson description]);
        return;
    }
    
    NSString *methodName = [mDictMethodInfo objectForKey:HFH_KEY_METHODNAME];
    
    if(methodName == nil) {
        NSLog(@"BridgeVCHfh %i, missing methodname from string:%@", __LINE__, strUrl);
        NSString *str = [NSString stringWithFormat:@"BridgeHelperHfh, %s, %i, Missing method name from string-%@", __FUNCTION__, __LINE__, strUrl];
        NSString *fName = [mDictMethodInfo objectForKey:HFH_KEY_ERROR_CALLBACK];
        [self callJsFunction:fName withArg:str];
        return;
    }
    
    SEL nativeMethod = NSSelectorFromString(methodName);
    if([self respondsToSelector:nativeMethod]) {
        void (*pFunc)(id, SEL, NSDictionary *);
        pFunc = (void (*)(id, SEL, NSDictionary *)) [self methodForSelector:nativeMethod];
        pFunc(self, nativeMethod, mDictMethodInfo);
    } else {
        NSLog(@"BridgeHelperHfh, %i, calling not implemented Objective C method - %@", __LINE__, methodName);
        NSString *str = [NSString stringWithFormat:@"BridgeHelperHfh, %s, %i, Calling not implemented Objective C method-%@", __FUNCTION__, __LINE__, methodName];
        NSString *fName = [mDictMethodInfo objectForKey:HFH_KEY_ERROR_CALLBACK];
        [self callJsFunction:fName withArg:str];
    }
}

#pragma mark Additional Methods
- (void) callLoadHome:(NSDictionary *)aDict {
    __weak BridgeHelperHfh *ctx = self;
    dispatch_async(dispatch_get_main_queue(), ^{ [ctx.bridgeListener callJsFunction:@"window.location = 'index.html';"]; });
}

@end
