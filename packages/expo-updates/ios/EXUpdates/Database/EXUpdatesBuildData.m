//  Copyright © 2021 650 Industries. All rights reserved.

#import <EXUpdates/EXUpdatesBuildData.h>
#import <EXUpdates/EXUpdatesDatabaseUtils.h>

NS_ASSUME_NONNULL_BEGIN

@implementation EXUpdatesBuildData

+ (BOOL)isBuildDataConsistent:(NSDictionary *)staticBuildData config:(EXUpdatesConfig *)config error:(NSError ** _Nullable)error;
{
  NSDictionary *impliedStaticBuildData = @{
    @"EXUpdatesURL":config.updateUrl.absoluteString,
    @"EXUpdatesReleaseChannel":config.releaseChannel,
    @"EXUpdatesRequestHeaders":config.requestHeaders,
  };
  return [staticBuildData isEqualToDictionary:impliedStaticBuildData
  ];
};

+ (void)ensureBuildDataIsConsistent:(EXUpdatesDatabase *)database scopeKey:(NSString *)scopeKey config:(EXUpdatesConfig *)config error:(NSError ** _Nullable)error;
{
  NSDictionary *staticBuildData = [database staticBuildDataWithScopeKey:scopeKey error:error];
  if(staticBuildData == nil){
    [self setBuildData:database scopeKey:scopeKey config:config error:error];

  } else {
    BOOL isConsistent = [self isBuildDataConsistent:staticBuildData config:config error:error];
    if (!isConsistent){
      [self clearAllUpdates:config database:database];
      [self setBuildData:database scopeKey:scopeKey config:config error:error];
    }
  }
  
}

+ (nullable NSDictionary *)getBuildData:(EXUpdatesDatabase *)database scopeKey:(NSString *)scopeKey error:(NSError ** _Nullable)error;
{
  NSDictionary *staticBuildData = [database staticBuildDataWithScopeKey:scopeKey error:error];
  
  return staticBuildData;
}

+ (void)setBuildData:(EXUpdatesDatabase *)database scopeKey:(NSString *)scopeKey config:(EXUpdatesConfig *)config error:(NSError ** _Nullable)error;
{
  NSDictionary *staticBuildData = @{
    @"EXUpdatesURL":config.updateUrl.absoluteString,
    @"EXUpdatesReleaseChannel":config.releaseChannel,
    @"EXUpdatesRequestHeaders":config.requestHeaders,
  };
  
  [database setStaticBuildDataWithScopeKey:staticBuildData withScopeKey:scopeKey error:nil];
}

+ (void)clearAllUpdates:(EXUpdatesConfig *)config
               database:(EXUpdatesDatabase *)database
{
  NSLog(@"clearing updates");
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
