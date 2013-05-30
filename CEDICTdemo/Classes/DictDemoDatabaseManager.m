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

// [lu:4 hua4] -> lǜ huà
// [lu:e4] => lüè
- (NSString*)transferPinyinSyllable:(NSString*)originalPinyin
{
    if (originalPinyin.length == 0 || originalPinyin == nil) return @"";
    
    NSArray* a = @[@"ā",@"á",@"ǎ",@"à",@"a"];
    NSArray* e = @[@"ē",@"é",@"ě",@"è",@"e"];
    NSArray* i = @[@"ī",@"í",@"ǐ",@"ì",@"i"];
    NSArray* o = @[@"ō",@"ó",@"ǒ",@"ò",@"o"];
    NSArray* u = @[@"ū",@"ú",@"ǔ",@"ù",@"u"];
    NSArray* v = @[@"ǖ",@"ǘ",@"ǚ",@"ǜ",@"ü"];
    
    NSMutableString *result = [NSMutableString string];
    
    NSArray *pinyins = [originalPinyin componentsSeparatedByString:@" "];
    for (NSString *pinyin in pinyins)
    {
        NSString *newpinyin;
        NSString *tone = [pinyin substringFromIndex:pinyin.length-1];
        
        newpinyin = [pinyin substringToIndex:pinyin.length - 1];
        if([tone integerValue] >= 1 && [tone integerValue] <= 5) //means it's a valid tone
        {
            if ([pinyin rangeOfString:@"a"].location != NSNotFound)
            {
                newpinyin = [newpinyin stringByReplacingOccurrencesOfString:@"a" withString:a[tone.integerValue-1]];
            }
            else if ([pinyin rangeOfString:@"e"].location != NSNotFound)
            {
                newpinyin = [newpinyin stringByReplacingOccurrencesOfString:@"e" withString:e[tone.integerValue-1]];
            }
            else if ([pinyin rangeOfString:@"ou"].location != NSNotFound)
            {
                newpinyin = [newpinyin stringByReplacingOccurrencesOfString:@"o" withString:o[tone.integerValue-1]];
            }
            else if ([pinyin rangeOfString:@"io"].location != NSNotFound)
            {
                newpinyin = [newpinyin stringByReplacingOccurrencesOfString:@"o" withString:o[tone.integerValue-1]];
            }
            else if ([pinyin rangeOfString:@"iu"].location != NSNotFound)
            {
                newpinyin = [newpinyin stringByReplacingOccurrencesOfString:@"u" withString:u[tone.integerValue-1]];
            }
            else if ([pinyin rangeOfString:@"ui"].location != NSNotFound)
            {
                newpinyin = [newpinyin stringByReplacingOccurrencesOfString:@"i" withString:i[tone.integerValue-1]];
            }
            else if ([pinyin rangeOfString:@"uo"].location != NSNotFound)
            {
                newpinyin = [newpinyin stringByReplacingOccurrencesOfString:@"o" withString:o[tone.integerValue-1]];
            }
            else if ([pinyin rangeOfString:@"i"].location != NSNotFound)
            {
                newpinyin = [newpinyin stringByReplacingOccurrencesOfString:@"i" withString:i[tone.integerValue-1]];
            }
            else if ([pinyin rangeOfString:@"o"].location != NSNotFound)
            {
                newpinyin = [newpinyin stringByReplacingOccurrencesOfString:@"o" withString:o[tone.integerValue-1]];
            }
            else if ([pinyin rangeOfString:@"u:"].location != NSNotFound)
            {
                newpinyin = [newpinyin stringByReplacingOccurrencesOfString:@"u:" withString:v[tone.integerValue-1]];
            }
            else if ([pinyin rangeOfString:@"u"].location != NSNotFound)
            {
                newpinyin = [newpinyin stringByReplacingOccurrencesOfString:@"u" withString:u[tone.integerValue-1]];
            }
        
        }
        
        if ([newpinyin rangeOfString:@"u:"].location != NSNotFound) {
            newpinyin = [newpinyin stringByReplacingOccurrencesOfString:@"u:" withString:@"ü"];
        }
        
        [result appendString:newpinyin];
        [result appendString:@" "];
    }
    
    return [result substringToIndex:result.length-1];
}


// select words start with prefix. eg: 中->中国,中心,中央,ect
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
