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

#import "InstanceDataHfh.h"

@implementation InstanceDataHfh

static InstanceDataHfh *instanceDataInstance;

- (id) init {
    if(self = [super init]) {
        _dictInstanceVaribles = [[NSMutableDictionary alloc] init];
        _arrayViews = [[NSMutableArray alloc] init];
        _arrayPerformJavaScript = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (InstanceDataHfh *) getInstanceData {
    if(instanceDataInstance == nil) {
        @synchronized(self) {
            if(instanceDataInstance == nil) {
                instanceDataInstance = [[InstanceDataHfh alloc] init];
            }
        }
    }
    return instanceDataInstance;
}

+ (void) releaseInstanceData {
    instanceDataInstance = nil;
}

@end
