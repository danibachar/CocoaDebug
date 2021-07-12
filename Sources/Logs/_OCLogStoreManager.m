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

static NSString *normalLogArrayPersistantStoreKey = @"com.cocoadebug.defaultLogArrayPersistantStore.key";
static NSString *webLogArrayPersistantStoreKey = @"com.cocoadebug.colorLogArrayPersistantStore.key";
static NSString *rnLogArrayPersistantStoreKey = @"com.cocoadebug.h5LogArrayPersistantStore.key";

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
    self.normalLogArray = [self fetchArrayOrCreateBy: normalLogArrayPersistantStoreKey];
    self.rnLogArray = [self fetchArrayOrCreateBy: rnLogArrayPersistantStoreKey];
    self.webLogArray = [self fetchArrayOrCreateBy: webLogArrayPersistantStoreKey];
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
    if (![log.content isKindOfClass:[NSString class]]) {return;}
    
    //log过滤, 忽略大小写
    for (NSString *prefixStr in [_NetworkHelper shared].onlyPrefixLogs) {
        if (![log.content hasPrefix:prefixStr]) {
            return;
        }
    }
    //log过滤, 忽略大小写
    for (NSString *prefixStr in [_NetworkHelper shared].ignoredPrefixLogs) {
        if ([log.content hasPrefix:prefixStr]) {
            return;
        }
    }
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    if (log.logType == CocoaDebugLogTypeNormal)
    {
        //normal
        if ([self.normalLogArray count] >= [[_NetworkHelper shared] logMaxCount]) {
            if (self.normalLogArray.count > 0) {
                [self.normalLogArray removeObjectAtIndex:0];
            }
        }
        
        [self.normalLogArray addObject:log];
        [self saveToDisk: self.normalLogArray byKey: normalLogArrayPersistantStoreKey];
    }
    else if (log.logType == CocoaDebugLogTypeRN)
    {
        //rn
        if ([self.rnLogArray count] >= [[_NetworkHelper shared] logMaxCount]) {
            if (self.rnLogArray.count > 0) {
                [self.rnLogArray removeObjectAtIndex:0];
            }
        }
        
        [self.rnLogArray addObject:log];
        [self saveToDisk: self.rnLogArray byKey: rnLogArrayPersistantStoreKey];
    }
    else
    {
        //web
        if ([self.webLogArray count] >= [[_NetworkHelper shared] logMaxCount]) {
            if (self.webLogArray.count > 0) {
                [self.webLogArray removeObjectAtIndex:0];
            }
        }
        
        [self.webLogArray addObject:log];
        [self saveToDisk: self.webLogArray byKey: webLogArrayPersistantStoreKey];
    }
    
    dispatch_semaphore_signal(semaphore);
}

- (void)removeLog:(_OCLogModel *)log
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    if (log.logType == CocoaDebugLogTypeNormal)
    {
        //normal
        [self.normalLogArray removeObject:log];
        [self saveToDisk:self.normalLogArray byKey:normalLogArrayPersistantStoreKey];
    }
    else if (log.logType == CocoaDebugLogTypeNormal)
    {
        //rn
        [self.rnLogArray removeObject:log];
        [self saveToDisk:self.rnLogArray byKey:rnLogArrayPersistantStoreKey];
    }
    else
    {
        //web
        [self.webLogArray removeObject:log];
        [self saveToDisk:self.webLogArray byKey:webLogArrayPersistantStoreKey];
    }
    
    dispatch_semaphore_signal(semaphore);
}

- (void)resetNormalLogs
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [self.normalLogArray removeAllObjects];
    [NSUserDefaults.standardUserDefaults removeObjectForKey: normalLogArrayPersistantStoreKey];
    dispatch_semaphore_signal(semaphore);
}

- (void)resetRNLogs
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [self.rnLogArray removeAllObjects];
    [NSUserDefaults.standardUserDefaults removeObjectForKey: rnLogArrayPersistantStoreKey];
    dispatch_semaphore_signal(semaphore);
}

- (void)resetWebLogs
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [self.webLogArray removeAllObjects];
    [NSUserDefaults.standardUserDefaults removeObjectForKey: webLogArrayPersistantStoreKey];
    dispatch_semaphore_signal(semaphore);
}

@end
