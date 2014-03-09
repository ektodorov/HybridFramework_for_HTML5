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

#import "ConstantsHfh.h"

/** HFH URI Schema prefix (jn - JavaScript to Native */
NSString * const HFH_SCHEMA_PREFIX = @"jn://";

/* HFH call keys in the JSON object passed as payload to the HFH URI Schema */
/* Key with Objective C method name that is called */
NSString * const HFH_KEY_METHODNAME = @"method";

/* Key with name of the JavaScript function which will be called on success */
NSString * const HFH_KEY_SUCCESS_CALLBACK = @"success";

/* Key with name of the JavaScript function which will be called on error */
NSString * const HFH_KEY_ERROR_CALLBACK = @"error";

/* Key with x position (int) */
NSString * const HFH_KEY_POSX = @"x";

/* Key with y position (int) */
NSString * const HFH_KEY_POSY = @"y";

/* Key with width size (int)*/
NSString * const HFH_KEY_WIDTH = @"width";

/* Key with height size (int) */
NSString * const HFH_KEY_HEIGHT = @"height";

/* Key with view index (int). Index in the Array of views created by JavaScript. */
NSString * const HFH_KEY_VIEWIDX = @"viewidx";

/* Key with button type (int).
 * One of:
 * ButtonTypeCustom = 0
 * ButtonTypeSystem = 1
 * ButtonTypeDetailDisclosure = 2
 * ButtonTypeInfoLight = 3
 * ButtonTypeInfoDark = 4
 * ButtonTypeContactAdd = 5
 * ButtonTypeRoundedRect = 6
 */
NSString * const HFH_KEY_BUTTONTYPE = @"buttontype";

/* Key with value for red color (int) */
NSString * const HFH_KEY_RED = @"red";

/* Key with value for green color (int) */
NSString * const HFH_KEY_GREEN = @"green";

/* Key with value for blue color (int) */
NSString * const HFH_KEY_BLUE = @"blue";

/* Key with value for alpha (int) */
NSString * const HFH_KEY_ALPHA = @"alpha";

/* Key with file path to an image */
NSString * const HFH_KEY_IMAGE = @"img";

/* Key with name of JavaScript function which will be used as callback onclick of native view */
NSString * const HFH_KEY_ONCLICK = @"onclick";

/* Key with name for title/lable of a view */
NSString * const HFH_KEY_TITLE = @"title";

/* Key with name of instance variable */
NSString * const HFH_KEY_NAME = @"name";

/* Key with value of instance variable */
NSString * const HFH_KEY_VALUE = @"value";

/* Key with file path */
NSString * const HFH_KEY_PATH = @"path";

/* Key with file path to docsdir */
NSString * const HFH_KEY_DOCSDIR = @"docsdir";

/* Key with file path to tempdir */
NSString * const HFH_KEY_TEMPDIR = @"tempdir";

/* Key with SQLite statement */
NSString * const HFH_KEY_SQL = @"sql";

/* Key with file path to HFH Command buffer file */
NSString * const HFH_KEY_BUFFER_FILEPATH = @"hfh_bufferfile_path";

/* Name of the HFH Command buffer file name */
NSString * const HFH_BUFFER_FILENAME = @"hfh_buffer_name";

@implementation ConstantsHfh

/* Replaces single quotes with double single quetes for use in SQLite statements */
+ (NSString *)escapeSingleQuotesForSQL:(NSString *)aString {
    NSString *escaped = [aString stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    return escaped;
}

/*
+ (NSArray *)escapeSingleQuotesInArray:(NSArray *)aArray {
    int arrayCount = [aArray count];
    NSMutableArray *retArray = [NSMutableArray arrayWithCapacity:arrayCount];
    for(int x = 0; x < arrayCount; x++) {
        NSString *str = [ConstantsHfh escapeSingleQuotesForSQL:[aArray objectAtIndex:x]];
        [retArray addObject:str];
    }
    return retArray;
}

+ (NSDictionary *)escapeSingleQuotesInDictionary:(NSDictionary *)aDict {
    NSMutableDictionary *retDict = [NSMutableDictionary dictionaryWithCapacity:[aDict count]];
    NSEnumerator *keyEnum = [aDict keyEnumerator];
    id dictKey = nil;
    while(dictKey = [keyEnum nextObject]) {
        [retDict setObject:[ConstantsHfh escapeSingleQuotesForSQL:[aDict objectForKey:dictKey]] forKey:dictKey];
    }
    return retDict;
}
*/

@end
