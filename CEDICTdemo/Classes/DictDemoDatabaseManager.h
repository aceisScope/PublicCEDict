//
//  DictDemoDatabaseManager.h
//  CEDICTdemo
//
//  Created by B.H.Liu on 13-5-29.
//  Copyright (c) 2013年 Appublisher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabaseQueue.h"
#import "FMDatabase.h"

@interface DictDemoDatabaseManager : NSObject

@property (nonatomic, strong) FMDatabase *db;

+ (DictDemoDatabaseManager*)sharedDataManager;

- (NSArray*)selectWordWithPrefix:(NSString*)prefix;

/*!
 to transfer a syllable pinyin tone to unicode, eg: zhong1 guo2 -> zhōng guó
 */
- (NSString*)transferPinyinSyllable:(NSString*)originalPinyin;

//this is the method for generating a database file from the given cedict text
- (void)insertAllCEDICTitemsIntoDB;


@end
