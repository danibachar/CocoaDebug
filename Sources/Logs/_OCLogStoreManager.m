//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_OCLogStoreManager.h"
#import "_NetworkHelper.h"

@interface _OCLogStoreManager ()
{
    dispatch_semaphore_t semaphore;
}
@end

static NSString *defaultLogArrayPersistantStoreKey = @"com.cocoadebug.defaultLogArrayPersistantStore.key";
static NSString *colorLogArrayPersistantStoreKey = @"com.cocoadebug.colorLogArrayPersistantStore.key";
static NSString *h5LogArrayPersistantStoreKey = @"com.cocoadebug.h5LogArrayPersistantStore.key";

@implementation _OCLogStoreManager

+ (instancetype)shared
{
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        semaphore = dispatch_semaphore_create(1);
        [self pouateLogsFromPersistantStore];
    }
    return self;
}

- (void)pouateLogsFromPersistantStore
{
    self.defaultLogArray = [self fetchArrayOrCreateBy:defaultLogArrayPersistantStoreKey];
    self.colorLogArray = [self fetchArrayOrCreateBy:colorLogArrayPersistantStoreKey];
    self.h5LogArray = [self fetchArrayOrCreateBy:h5LogArrayPersistantStoreKey];
}

- (void)saveToDisk:(NSArray<_OCLogModel*>*)array byKey:(NSString*)key
{
    if (array.count == 0) { return; }
    NSMutableArray<NSData*> *archiveArray = [NSMutableArray arrayWithCapacity:array.count];
    for (_OCLogModel* log in array) {
        NSData *logData = [NSKeyedArchiver archivedDataWithRootObject:log];
        [archiveArray addObject:logData];
    }
    [NSUserDefaults.standardUserDefaults setObject: [archiveArray copy] forKey: key];
}

- (NSMutableArray<_OCLogModel*>*)fetchArrayOrCreateBy:(NSString*)key
{
    NSMutableArray<_OCLogModel*> *unArchiveArray = [NSMutableArray arrayWithCapacity:[[_NetworkHelper shared] logMaxCount]];
    if ([NSUserDefaults.standardUserDefaults objectForKey: key] != nil) {
        NSArray<NSData*> *dataArray = [NSUserDefaults.standardUserDefaults objectForKey: key];
        for (NSData* logData in dataArray) {
            _OCLogModel* log = [NSKeyedUnarchiver unarchiveObjectWithData:logData];
            [unArchiveArray addObject:log];
        }
    }
    return unArchiveArray;
}

- (void)addLog:(_OCLogModel *)log
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    if (log.h5LogType == H5LogTypeNone)
    {
        if (log.color == [UIColor whiteColor] || log.color == nil)
        {
            //白色
            if ([self.defaultLogArray count] >= [[_NetworkHelper shared] logMaxCount]) {
                if (self.defaultLogArray.count > 0) {
                    [self.defaultLogArray removeObjectAtIndex:0];
                }
            }
            
            [self.defaultLogArray addObject:log];
            [self saveToDisk:self.defaultLogArray byKey:defaultLogArrayPersistantStoreKey];
        }
        else
        {
            //彩色
            if ([self.colorLogArray count] >= [[_NetworkHelper shared] logMaxCount]) {
                if (self.colorLogArray.count > 0) {
                    [self.colorLogArray removeObjectAtIndex:0];
                }
            }
            
            [self.colorLogArray addObject:log];
            [self saveToDisk:self.colorLogArray byKey:colorLogArrayPersistantStoreKey];
        }
    }
    else
    {
        //H5
        if ([self.h5LogArray count] >= [[_NetworkHelper shared] logMaxCount]) {
            if (self.h5LogArray.count > 0) {
                [self.h5LogArray removeObjectAtIndex:0];
            }
        }
        
        [self.h5LogArray addObject:log];
        [self saveToDisk:self.h5LogArray byKey:h5LogArrayPersistantStoreKey];
    }
    
    dispatch_semaphore_signal(semaphore);
}

- (void)removeLog:(_OCLogModel *)log
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    if (log.h5LogType == H5LogTypeNone)
    {
        if (log.color == [UIColor whiteColor] || log.color == nil) {
            [self.defaultLogArray removeObject:log];
            [self saveToDisk:self.defaultLogArray byKey:defaultLogArrayPersistantStoreKey];
        } else {
            [self.colorLogArray removeObject:log];
            [self saveToDisk:self.colorLogArray byKey:colorLogArrayPersistantStoreKey];
        }
    }
    else
    {
        [self.h5LogArray removeObject:log];
        [self saveToDisk:self.h5LogArray byKey:h5LogArrayPersistantStoreKey];
    }
    
    dispatch_semaphore_signal(semaphore);
}

- (void)resetDefaultLogs
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [self.defaultLogArray removeAllObjects];
    [NSUserDefaults.standardUserDefaults removeObjectForKey: defaultLogArrayPersistantStoreKey];
    dispatch_semaphore_signal(semaphore);
}

- (void)resetColorLogs
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [self.colorLogArray removeAllObjects];
    [NSUserDefaults.standardUserDefaults removeObjectForKey: colorLogArrayPersistantStoreKey];
    dispatch_semaphore_signal(semaphore);
}

- (void)resetH5Logs
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [self.h5LogArray removeAllObjects];
    [NSUserDefaults.standardUserDefaults removeObjectForKey: h5LogArrayPersistantStoreKey];
    dispatch_semaphore_signal(semaphore);
}

@end
