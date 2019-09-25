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

@protocol BridgeListenerHfh <NSObject>

/** Performs JavaScript function in the attached main WebView
 * @param (NSString *)aFunctionAndArgs - JavaScript function containing the arguments - myFunction(someArg, someOtherArg);
 * @return void
 */
- (void)callJsFunction:(NSString *)aFunctionAndArgs;

- (void)callAddSubView:(UIView *)aView;

- (UIWebView *)getWebViewMain;

- (void)callShowCamera;
- (void)callShowPhotoLibrary;

- (void)callShowAddressBook;

- (void)callBeginDeviceOrientationNotif;
- (void)callEndDeviceOrientationNotif;

@end
