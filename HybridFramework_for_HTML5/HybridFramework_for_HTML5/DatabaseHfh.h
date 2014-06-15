
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
#import <sqlite3.h>

@interface DatabaseHfh : NSObject
{
@private
    NSString *mDbPath;
    bool isOpen;
    NSString *strQuery;
    sqlite3 *db;
    sqlite3_stmt *stmt;
    char *errMsg;
    int rowIndex;
    int rowCount;
}
/**
 *  Opens a database or creates it if doesn't exist in the specified path
 *  @param aDbPath - file path including the file name
 */
- (bool) openOrCreate:(NSString *) aDbPath;

/** @Return Result code of SQLite execution */
- (int)getErrorCode;

/** @Return Error message of SQLite execution */
- (NSString *)getErrorMsg;

/** Executes a SQLite query which doesn't return rows */
- (bool) execSQLite:(NSString *) aQuery;

/** Executes a SQLite query and returns the result rows */
- (int) execQuery:(NSString *) aQuery;

/** Evaluates a SQLite query and prepares in for execution */
- (void) prepareQuery:(NSString *) aQuery;

/** Moves to the next row from the query */
- (int) moveToNext;

/** Executes a SQLite query that was prepared with <code>prepareQuery</code> and returns the first row */
- (bool) getNextRow;

/** Evaluates if the current row is the first from the answer of the query */
- (bool) isFirst;

/** Evaluates if the current row is the last from the answer of the query */
- (bool) isLast;

/** Evaluates if there are more rows from the query */
- (bool) hasNext;

/** @return - Returns the number of columns in the result */
- (int) getColumnCount;

/** @retrun - Returns the number of rows returned from the query */
- (int) getRowCount;

/**
 *  @return - Returns the name of the column at the specified column index
 *  @param aColumnIndex - the index of the column, zero based
 */
- (NSString *) getColumnName:(int) aColumnIndex;

/**
 *  @return - Returns (NSString *) the content of the column at the specified column index
 *  @param aColumnIndex - the index of the column, zero based
 */
- (NSString *) getTextColumn:(int) aColumnIndex;

/** @return - Returns (int) the content of the column at the specified column index */
- (int) getIntColumn:(int) aColumnIndex;

/** @return - Returns (double) the content of the column at the specified column index */
- (double) getDoubleColumn:(int) aColumnIndex;

/** 
 *  Finalizes the statement used for the query
 *  (should call this only if you don't go throught all the rows of the resutl. If you have went throught all the rows
 *  finalized is called int <code>moveToNext</code> and <code>getNextRow</code> methods.
 */
- (bool)doneWithStatement;
- (bool)closeStatement;

/** Finalizes the sqlite3_stmt and closes the connection to the database */
- (bool) closeDb;

/** @return - Returns the error message from an execSQLite */
- (NSString *) getErrorMessage;

/* Exposing work directly with sqlite3_stmt so that the user can keep refernces and reuse them */
- (int)prepareStmt:(NSString *)aQuery sqlite3Stmt:(sqlite3_stmt *)aSqlite3Stmt;
- (int)moveToNextRow:(sqlite3_stmt *)aSqlite3PreparedStmt;
- (int)resetStmt:(sqlite3_stmt *)aSqlite3PreparedStmt;
- (bool)closeDbAndStmts;

@end
