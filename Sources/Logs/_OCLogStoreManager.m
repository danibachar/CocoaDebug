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
    if ([NSUserDefaults.standardUserDefaults objectForKey: defaultLogArrayPersistantStoreKey] != nil) {
        self.defaultLogArray = [NSMutableArray arrayWithArray: [NSUserDefaults.standardUserDefaults objectForKey: defaultLogArrayPersistantStoreKey]];
    } else {
        self.defaultLogArray = [NSMutableArray arrayWithCapacity: [[_NetworkHelper shared] logMaxCount]];
    }
    
    if ([NSUserDefaults.standardUserDefaults objectForKey: colorLogArrayPersistantStoreKey] != nil) {
        self.colorLogArray = [NSMutableArray arrayWithArray: [NSUserDefaults.standardUserDefaults objectForKey: colorLogArrayPersistantStoreKey]];
    } else {
        self.colorLogArray = [NSMutableArray arrayWithCapacity:[[_NetworkHelper shared] logMaxCount]];
    }
    
    if ([NSUserDefaults.standardUserDefaults objectForKey: h5LogArrayPersistantStoreKey] != nil) {
        self.h5LogArray = [NSMutableArray arrayWithArray: [NSUserDefaults.standardUserDefaults objectForKey: h5LogArrayPersistantStoreKey]];
    } else {
        self.h5LogArray = [NSMutableArray arrayWithCapacity:[[_NetworkHelper shared] logMaxCount]];
    }
    
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
            [NSUserDefaults.standardUserDefaults setObject: self.defaultLogArray
                                                    forKey: defaultLogArrayPersistantStoreKey];
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
            [NSUserDefaults.standardUserDefaults setObject: self.colorLogArray
                                                    forKey: colorLogArrayPersistantStoreKey];
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
        [NSUserDefaults.standardUserDefaults setObject:self.h5LogArray
                                                forKey: h5LogArrayPersistantStoreKey];
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
            [NSUserDefaults.standardUserDefaults setObject: self.defaultLogArray
                                                    forKey: defaultLogArrayPersistantStoreKey];
        } else {
            [self.colorLogArray removeObject:log];
            [NSUserDefaults.standardUserDefaults setObject: self.colorLogArray
                                                    forKey: colorLogArrayPersistantStoreKey];
        }
    }
    else
    {
        [self.h5LogArray removeObject:log];
        [NSUserDefaults.standardUserDefaults setObject: self.h5LogArray
                                                forKey: h5LogArrayPersistantStoreKey];
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
