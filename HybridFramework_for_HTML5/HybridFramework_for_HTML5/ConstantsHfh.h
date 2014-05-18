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

/** HFH URI Schema prefix */
extern NSString * const HFH_SCHEMA_PREFIX;

/* HFH call keys in the JSON object passed as payload to the HFH URI Schema */
extern NSString * const HFH_KEY_METHODNAME;
//extern NSString * const HFH_KEY_ARGS_ARRAY;
extern NSString * const HFH_KEY_SUCCESS_CALLBACK;
extern NSString * const HFH_KEY_ERROR_CALLBACK;

/* HFH keys in the NSDictionary passed to Objective C methods */
extern NSString * const HFH_KEY_POSX;
extern NSString * const HFH_KEY_POSY;
extern NSString * const HFH_KEY_WIDTH;
extern NSString * const HFH_KEY_HEIGHT;
extern NSString * const HFH_KEY_VIEWIDX;

/**
 * ButtonTypeCustom = 0
 * ButtonTypeSystem = 1
 * ButtonTypeDetailDisclosure = 2
 * ButtonTypeInfoLight = 3
 * ButtonTypeInfoDark = 4
 * ButtonTypeContactAdd = 5
 * ButtonTypeRoundedRect = 6
 */
extern NSString * const HFH_KEY_BUTTONTYPE;
extern NSString * const HFH_KEY_COLOR;
extern NSString * const HFH_KEY_RED;
extern NSString * const HFH_KEY_GREEN;
extern NSString * const HFH_KEY_BLUE;
extern NSString * const HFH_KEY_ALPHA;
extern NSString * const HFH_KEY_IMAGE;
extern NSString * const HFH_KEY_RECTANGLE;
extern NSString * const HFH_KEY_ONCLICK;
extern NSString * const HFH_KEY_TITLE;
extern NSString * const HFH_KEY_VIEWRESIZINGMASK;
extern NSString * const HFH_KEY_NAME;
extern NSString * const HFH_KEY_VALUE;
extern NSString * const HFH_KEY_PATH;
extern NSString * const HFH_KEY_DOCSDIR;
extern NSString * const HFH_KEY_TEMPDIR;
extern NSString * const HFH_KEY_SQL;
extern NSString * const HFH_KEY_BUFFER_FILEPATH;

/* File command buffer 
 *   UIViewAutoresizingNone                 = 0,
 *   UIViewAutoresizingFlexibleLeftMargin   = 1     //1 << 0,
 *   UIViewAutoresizingFlexibleWidth        = 2     //1 << 1,
 *   UIViewAutoresizingFlexibleRightMargin  = 4     //1 << 2,
 *   UIViewAutoresizingFlexibleTopMargin    = 8     //1 << 3,
 *   UIViewAutoresizingFlexibleHeight       = 16    //1 << 4,
 *   UIViewAutoresizingFlexibleBottomMargin = 32    //1 << 5
 */
extern NSString * const HFH_BUFFER_FILENAME;

@interface ConstantsHfh : NSObject

+ (NSString *)escapeSingleQuotesForSQL:(NSString *)aString;

@end
