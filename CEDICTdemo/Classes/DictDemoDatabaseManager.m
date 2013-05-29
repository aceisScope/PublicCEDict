//
//  DictDemoDatabaseManager.m
//  CEDICTdemo
//
//  Created by B.H.Liu on 13-5-29.
//  Copyright (c) 2013年 Appublisher. All rights reserved.
//

#import "DictDemoDatabaseManager.h"
#import "FileReader.h"

#define DB_PATH [[NSBundle mainBundle] pathForResource:@"cedict" ofType:@"db3"]

#define PRE_DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"cedict.db3"]

static DictDemoDatabaseManager *dbmanager = nil;

@implementation DictDemoDatabaseManager

+ (DictDemoDatabaseManager*)sharedDataManager
{
    {
        if (dbmanager == nil) {
            
            dbmanager = [[DictDemoDatabaseManager alloc] init];
        }
        return dbmanager; 
    }
}

- (id)init
{
    self = [super init];
    if (self)
    {
        NSFileManager *filemanager = [NSFileManager defaultManager];
        BOOL isExist = [filemanager fileExistsAtPath:DB_PATH];
        
        self.db = [FMDatabase databaseWithPath:DB_PATH];
        [self.db open];
        
        if (![self.db open]) {
            NSLog(@"can not open dict db");
            return self;
        }
    
        if (!isExist)
        {                
            [self.db executeUpdate:[NSString stringWithFormat:@"CREATE TABLE cedict (id INTEGER PRIMARY KEY , simplified TEXT COLLATE nocase, traditional TEXT COLLATE nocase, pinyin TEXT COLLATE nocase , english TEXT COLLATE nocase, UNIQUE  ('simplified' ASC) ON CONFLICT REPLACE )"]];
            
            // create indexs
            [self.db executeUpdate:[NSString stringWithFormat:@"CREATE INDEX index_simplified ON cedict (simplified ASC)"]];
            
            NSLog(@"create table dict");
        }
        
    }
    
    return self;
}

- (void)insertAllCEDICTitemsIntoDB
{
    FileReader* fileReader =[[FileReader alloc] initWithFilePath:[[NSBundle mainBundle]pathForResource:@"cedict_1_0_ts_utf-8_mdbg" ofType:@"txt"]];
    if (!fileReader)
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"CEDICT file does not exist in bundle" userInfo:nil];
    
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:PRE_DB_PATH];
    
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback)
    {
        NSString* line = nil;
        NSArray *array1 = [NSArray array];
        NSArray *array2 = [NSArray array];
        
        while ((line = [fileReader readLine]))
        {
            /*!
             structure of "array1"
             [ AA制 AA制 [A A zhi4] ,"to split the bill", "to go Dutch", "\r\n" ]
             */
            array1 = [line componentsSeparatedByString:@"/"];
            /*!
             structure of "array2"
             [ AA制,AA制,[A,A,zhi4]," " ]
             */
            array2 = [array1[0] componentsSeparatedByString:@" "];
            
            NSString *traditional = array2[0];
            NSString *simplified = array2[1];
            NSString *pinyin = [array1[0] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"[]"]][1];
            NSString *english = [[array1 subarrayWithRange:NSMakeRange(1, array1.count - 2)] componentsJoinedByString:@"/"];
            
            if ([db executeUpdate:@"INSERT INTO cedict (simplified,traditional,pinyin,english) VALUES (?,?,?,?)",simplified,traditional,pinyin,english])
            {
                NSLog(@"insert success");
            }
            else
            {
                NSLog(@"insert failure");
            }
        }
        
    }];
    
}

- (NSArray*)selectWordWithPrefix:(NSString*)prefix
{
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM cedict WHERE simplified LIKE \"%@%@\" ORDER BY id", prefix,@"%"];
    FMResultSet * words = [self.db executeQuery:query];
    NSMutableArray * results = [NSMutableArray array];
    while ([words next])
    {
        [results addObject:@{
         @"simplified": [words stringForColumn:@"simplified"],
         @"traditional":[words stringForColumn:@"traditional"],
         @"pinyin":[words stringForColumn:@"pinyin"],
         @"english":[words stringForColumn:@"english"]
         }
         ];
    }
    return results;

}

@end