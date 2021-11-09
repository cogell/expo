//  Copyright © 2021 650 Industries. All rights reserved.

#import <EXUpdates/EXUpdatesBuildData.h>
#import <EXUpdates/EXUpdatesDatabaseUtils.h>

NS_ASSUME_NONNULL_BEGIN

@implementation EXUpdatesBuildData

+ (void)ensureBuildDataIsConsistent:(EXUpdatesDatabase *)database scopeKey:(NSString *)scopeKey config:(EXUpdatesConfig *)config error:(NSError ** _Nullable)error;
{
  
  __block NSDictionary *staticBuildData;
  dispatch_sync(database.databaseQueue, ^{
    staticBuildData = [database staticBuildDataWithScopeKey:scopeKey error:nil];
  });
  
  if(staticBuildData == nil){
    [self setBuildDataInDatabase:database config:config];
  } else {
    NSDictionary *impliedStaticBuildData = [self getBuildDataFromConfig:config];
    BOOL isConsistent = [staticBuildData isEqualToDictionary:impliedStaticBuildData];
    if (!isConsistent){
      [self clearAllUpdates:config database:database];
      [self setBuildDataInDatabase:database config:config];
    }
  }
  
}

+ (nullable NSDictionary *)getBuildDataFromDatabase:(EXUpdatesDatabase *)database scopeKey:(NSString *)scopeKey error:(NSError ** _Nullable)error;
{
  NSDictionary *staticBuildData = [database staticBuildDataWithScopeKey:scopeKey error:error];
  return staticBuildData;
}

+ (nullable NSDictionary *)getBuildDataFromConfig:(EXUpdatesConfig *)config;
{
  return @{
    @"EXUpdatesURL":config.updateUrl.absoluteString,
    @"EXUpdatesReleaseChannel":config.releaseChannel,
    @"EXUpdatesRequestHeaders":config.requestHeaders,
  };
}

+ (void)setBuildDataInDatabase:(EXUpdatesDatabase *)database config:(EXUpdatesConfig *)config;
{
  dispatch_async(database.databaseQueue, ^{
    [database setStaticBuildData:[self getBuildDataFromConfig:config] withScopeKey:config.scopeKey];
  });
}

+ (void)clearAllUpdates:(EXUpdatesConfig *)config
               database:(EXUpdatesDatabase *)database
{
  dispatch_async(database.databaseQueue, ^{
    NSError *error;
    NSArray<EXUpdatesUpdate *> *allUpdates = [database allUpdatesWithConfig:config error:&error];
    if (!allUpdates || error) {
      NSLog(@"Error clearing updates: %@", error.localizedDescription);
      return;
    }
    
    [database deleteUpdates:allUpdates error:&error];
    if (error) {
      NSLog(@"Error clearing updates: %@", error.localizedDescription);
      return;
    }
  });
}

@end

NS_ASSUME_NONNULL_END
