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

#import "DatabaseHfh.h"

@implementation DatabaseHfh

- (int)getErrorCode
{
    int errorCode = sqlite3_errcode(db);
    return errorCode;
}

- (NSString *)getErrorMsg
{
    const char *msg;
    msg = sqlite3_errmsg(db);
    NSString *strMsg = nil;
    if(msg != NULL) {strMsg = [NSString stringWithUTF8String:msg];}
    return strMsg;
}

- (NSString *)getErrorMessage
{
    NSString *error = nil;
    if(errMsg != NULL) {
        error = [[NSString alloc] initWithUTF8String:errMsg];
    } else {
        error = [self getErrorMsg];
    }
    return error;
}

- (bool) openOrCreate:(NSString *) aDbPath
{
    const char *path = [aDbPath UTF8String];
    if(sqlite3_open(path, &db) == SQLITE_OK) {
        return true;
    } else {
        NSLog(@"%s, %i, sqlite errorCode=%i, sqlite error msg=%@", __func__, __LINE__, [self getErrorCode], [self getErrorMsg]);
        return false;
    }
}

- (bool) execSQLite:(NSString *) aQuery
{
    const char *query = [aQuery UTF8String];
    int retVal;
    
    retVal = sqlite3_exec(db, query, NULL, NULL, &errMsg);
    if(retVal != SQLITE_OK) {
        NSLog(@"%s, %i, errorCode=%i, errorMsg=%@", __func__, __LINE__, retVal, [self getErrorMsg]);
        return false;
    } else {
        return true;
    }
}

- (int) execQuery:(NSString *) aQuery
{
    strQuery = aQuery;
    rowCount = -1;
    const char *query = [aQuery UTF8String];
    int retVal;
    
    sqlite3_prepare_v2(db, query, -1, &stmt, NULL);
    retVal = sqlite3_step(stmt);
    if (retVal == SQLITE_ROW) {
        rowIndex = 0;
    } else if(retVal == SQLITE_DONE) {
        if(stmt != NULL) {
            sqlite3_finalize(stmt);
            stmt = NULL;
        }
    }
    if(retVal == SQLITE_ERROR) {NSLog(@"%s, %i, erroCode=%i, errorMsg=%@", __func__, __LINE__, retVal, [self getErrorMsg]);}
    return retVal;
}

- (void) prepareQuery:(NSString *) aQuery
{
    strQuery = aQuery;
    rowCount = -1;
    const char *query = [aQuery UTF8String];
    sqlite3_prepare_v2(db, query, -1, &stmt, NULL);
}

- (int) moveToNext
{
    int retVal;
    retVal = sqlite3_step(stmt);
    if(retVal == SQLITE_ROW) {
        rowIndex++;
    }
    if(retVal == SQLITE_DONE) {
        if(stmt != NULL) {
            sqlite3_finalize(stmt);
            stmt = NULL;
        }
    }
    if(retVal == SQLITE_ERROR) {NSLog(@"%s, %i, erroCode=%i", __func__, __LINE__, retVal);}
    return retVal;
}

- (bool) getNextRow
{
    int retVal;
    retVal = sqlite3_step(stmt);
    if(rowCount == -1) { rowCount = 0; }
    if(retVal == SQLITE_ROW) {
        rowIndex++;
    }
    if(retVal == SQLITE_ROW) {
        return true;
    } else {
        if(retVal == SQLITE_DONE) {
            if(stmt != NULL) {
                sqlite3_finalize(stmt);
                stmt = NULL;
            }
        }
        NSLog(@"%s, %i, retVal=%i", __func__, __LINE__, retVal);
        return false;
    }
}

- (bool) isFirst
{
    if (rowIndex == 0) {
        return true;
    } else {
        return false;
    }
}

- (bool) isLast
{
    if (rowIndex == ([self getRowCount] - 1)) {
        return true;
    } else {
        return false;
    }
    
}

- (bool) hasNext
{
    if (rowIndex < ([self getRowCount] - 1)) {
        return true;
    } else {
        return false;
    }
}

- (int) getColumnCount
{
    int columnCount = sqlite3_column_count(stmt);
    return columnCount;
}

- (int) getRowCount
{
    if (rowCount == -1) {
        int stepVal;
        sqlite3_stmt *tempStmt;
        const char *query = [strQuery UTF8String];
        sqlite3_prepare_v2(db, query, -1, &tempStmt, NULL);
        while(true) {
            stepVal = sqlite3_step(tempStmt);
            if(stepVal == SQLITE_ROW) {
                rowCount++;
            }
            if(stepVal == SQLITE_DONE) {
                break;
            }
        }
        sqlite3_finalize(tempStmt);
        return rowCount;
    } else {
        return rowCount;
    }
}

- (NSString *) getColumnName:(int) aColumnIndex
{
    NSString *name = [[NSString alloc] initWithUTF8String: (const char*) sqlite3_column_name(stmt, aColumnIndex)];
    return name;
}

- (NSString *) getTextColumn:(int) aColumnIndex
{
    NSString *temp = nil;
    const char *val = (const char *)sqlite3_column_text(stmt, aColumnIndex);
    if(val != NULL) {
        temp = [[NSString alloc] initWithUTF8String:val];
    }
    return temp;
}

- (int) getIntColumn:(int) aColumnIndex
{
    int temp = sqlite3_column_int(stmt, aColumnIndex);
    return temp;
}

- (double) getDoubleColumn:(int) aColumnIndex
{
    double temp = sqlite3_column_double(stmt, aColumnIndex);
    return temp;
}

- (bool) doneWithStatement
{
    if(stmt != NULL) {
        if(sqlite3_finalize(stmt) == SQLITE_OK) {
            stmt = NULL;
            return true;
        } else {
            NSLog(@"%s, %i, sqlite errorCode=%i, sqlite error msg=%@", __func__, __LINE__, [self getErrorCode], [self getErrorMsg]);
            return false;
        }
    }
    return true;
}

- (bool)closeStatement
{
    if(stmt != NULL) {
        if(sqlite3_finalize(stmt) == SQLITE_OK) {
            stmt = NULL;
            return true;
        } else {
            NSLog(@"%s, %i, sqlite errorCode=%i, sqlite error msg=%@", __func__, __LINE__, [self getErrorCode], [self getErrorMsg]);
            return false;
        }
    }
    return true;
}

- (bool) closeDb
{
    if(stmt != NULL) {
        sqlite3_finalize(stmt);
        stmt = NULL;
    }
    if(sqlite3_close(db) == SQLITE_OK) {
        return true;
    }
    NSLog(@"%s, %i, sqlite errorCode=%i, sqlite error msg=%@", __func__, __LINE__, [self getErrorCode], [self getErrorMsg]);
    return false;
}

 /* Exposing work directly with sqlite3_stmt so that the user can keep refernces and reuse them */
 - (int)prepareStmt:(NSString *)aQuery sqlite3Stmt:(sqlite3_stmt *)aSqlite3Stmt
 {
	const char *query = [aQuery UTF8String];
	return sqlite3_prepare_v2(db, query, -1, &aSqlite3Stmt, NULL);
 }
 
 - (int)moveToNextRow:(sqlite3_stmt *)aSqlite3PreparedStmt
 {
	int retVal;
	retVal = sqlite3_step(aSqlite3PreparedStmt);
	if(retVal == SQLITE_ROW) {
		rowIndex++;
  	}
  	if(retVal == SQLITE_DONE) {
  		if(aSqlite3PreparedStmt != NULL) {
  			sqlite3_reset(aSqlite3PreparedStmt);
  		}
  	}
  	if(retVal == SQLITE_ERROR) {NSLog(@"%s, %i, erroCode=%i", __func__, __LINE__, retVal);}
 
	return retVal;
 }
 
 - (int)resetStmt:(sqlite3_stmt *)aSqlite3PreparedStmt
 {
  	return sqlite3_reset(aSqlite3PreparedStmt);
 }
 
 - (bool)closeDbAndStmts
 {
  	if(stmt != NULL) {
  	sqlite3_finalize(stmt);
  	stmt = NULL;
  	}
  	sqlite3_stmt *tempStmt;
  	while((tempStmt = sqlite3_next_stmt(db, NULL)) != NULL) {
  		sqlite3_finalize(tempStmt);
  	}
  	if(sqlite3_close(db) == SQLITE_OK) {
  		return true;
  	}
  	NSLog(@"%s, %i, sqlite errorCode=%i, sqlite error msg=%@", __func__, __LINE__, [self getErrorCode], [self getErrorMsg]);
 
	return false;
 }

@end
