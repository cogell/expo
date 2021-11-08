//  Copyright (c) 2021 650 Industries, Inc. All rights reserved.

#import <XCTest/XCTest.h>

#import <EXManifests/EXManifestsNewManifest.h>
#import <EXUpdates/EXUpdatesNewUpdate.h>
#import <EXUpdates/EXUpdatesDatabase.h>
#import <EXUpdates/EXUpdatesBuildData.h>

#import <OCMockito/OCMockito.h>

@interface EXUpdatesBuildDataTests : XCTestCase

@property (nonatomic, strong) EXUpdatesDatabase *db;
@property (nonatomic, strong) NSURL *testDatabaseDir;
@property (nonatomic, strong) EXManifestsNewManifest *manifest;
@property (nonatomic, strong) NSDictionary *configChannelTestDictionary;
@property (nonatomic, strong) EXUpdatesConfig *configChannelTest;
@property (nonatomic, strong) NSDictionary *configChannelTestTwoDictionary;
@property (nonatomic, strong) EXUpdatesConfig *configChannelTestTwo;

@end

static NSString * const scopeKey = @"test";


@implementation EXUpdatesBuildDataTests

- (void)setUp {
  NSURL *applicationSupportDir = [NSFileManager.defaultManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask].lastObject;
  _testDatabaseDir = [applicationSupportDir URLByAppendingPathComponent:@"EXUpdatesDatabaseTests"];
  if (![NSFileManager.defaultManager fileExistsAtPath:_testDatabaseDir.path]) {
    NSError *error;
    [NSFileManager.defaultManager createDirectoryAtPath:_testDatabaseDir.path withIntermediateDirectories:YES attributes:nil error:&error];
    XCTAssertNil(error);
  }
  
  _db = [[EXUpdatesDatabase alloc] init];
  dispatch_sync(_db.databaseQueue, ^{
    NSError *dbOpenError;
    [_db openDatabaseInDirectory:_testDatabaseDir withError:&dbOpenError];
    XCTAssertNil(dbOpenError);
  });
  
  _manifest = [[EXManifestsNewManifest alloc] initWithRawManifestJSON:@{
    @"runtimeVersion": @"1",
    @"id": @"0eef8214-4833-4089-9dff-b4138a14f196",
    @"createdAt": @"2020-11-11T00:17:54.797Z",
    @"launchAsset": @{@"url": @"https://url.to/bundle.js", @"contentType": @"application/javascript"}
  }];
  
  
  _configChannelTestDictionary = @{
    @"EXUpdatesURL": @"https://exp.host/@test/test",
    @"EXUpdatesReleaseChannel": @"default",
    @"EXUpdatesRequestHeaders": @{@"expo-channel-name":@"test"}
  };
  _configChannelTest = [EXUpdatesConfig configWithDictionary:_configChannelTestDictionary];
  _configChannelTestTwoDictionary = @{
    @"EXUpdatesURL": @"https://exp.host/@test/test",
    @"EXUpdatesReleaseChannel": @"default",
    @"EXUpdatesRequestHeaders": @{@"expo-channel-name":@"testTwo"}
  };
  _configChannelTestTwo = [EXUpdatesConfig configWithDictionary:_configChannelTestTwoDictionary
  ];
}

- (void)tearDown
{
  dispatch_sync(_db.databaseQueue, ^{
    [_db closeDatabase];
  });
  NSError *error;
  [NSFileManager.defaultManager removeItemAtPath:_testDatabaseDir.path error:&error];
  XCTAssertNil(error);
}

- (void)test_clearAllUpdates {
  EXUpdatesUpdate *update = [EXUpdatesNewUpdate updateWithNewManifest:_manifest response:nil config:_configChannelTest database:_db];
  
  dispatch_sync(_db.databaseQueue, ^{
    NSError *updatesError;
    [_db addUpdate:update error:&updatesError];
    if (updatesError) {
      XCTFail(@"%@", updatesError.localizedDescription);
      return;
    }
  });

  dispatch_sync(_db.databaseQueue, ^{
    NSError *queryError;
    NSArray<EXUpdatesUpdate *> *allUpdates = [_db allUpdatesWithConfig:_configChannelTest error:&queryError];
    if (queryError) {
      XCTFail(@"%@", queryError.localizedDescription);
      return;
    }
    
    XCTAssertGreaterThan(allUpdates.count, 0);
  });
  
  
  [EXUpdatesBuildData clearAllUpdates:_configChannelTest database:_db];
  
  dispatch_sync(_db.databaseQueue, ^{
    NSError *queryError;
    NSArray<EXUpdatesUpdate *> *allUpdates = [_db allUpdatesWithConfig:_configChannelTest error:&queryError];
    if (queryError) {
      XCTFail(@"%@", queryError.localizedDescription);
      return;
    }
    
    XCTAssertEqual(allUpdates.count, 0);
  });
}

- (void)test_ensureBuildDataIsConsistent_buildDataIsNull {
  // check no updates and build data is set

  dispatch_sync(_db.databaseQueue, ^{
    NSError *error;
    
    NSDictionary *staticBuildData = [EXUpdatesBuildData getBuildData:_db scopeKey:scopeKey error:&error];
    XCTAssertNil(staticBuildData);

    NSArray<EXUpdatesUpdate *> *allUpdates = [_db allUpdatesWithConfig:_configChannelTest error:&error];
    XCTAssertEqual(allUpdates.count, 0);

    [EXUpdatesBuildData ensureBuildDataIsConsistent:_db scopeKey:scopeKey config:_configChannelTest error:&error];

    NSDictionary *newStaticBuildData = [EXUpdatesBuildData getBuildData:_db scopeKey:scopeKey error:&error];
    XCTAssertNotNil(newStaticBuildData);

    
    
    XCTAssertNil(error);
  });
  
  
}

- (void)test_ensureBuildDataIsConsistent_buildDataIsConsistent {
  EXUpdatesUpdate *update = [EXUpdatesNewUpdate updateWithNewManifest:_manifest response:nil config:_configChannelTest database:_db];
  
  dispatch_sync(_db.databaseQueue, ^{
    NSError *error;
    [_db addUpdate:update error:&error];
    [EXUpdatesBuildData setBuildData:_db scopeKey:scopeKey config:_configChannelTest error:&error];
    
    [EXUpdatesBuildData ensureBuildDataIsConsistent:_db scopeKey:scopeKey config:_configChannelTest error:&error];
    
    NSDictionary *staticBuildData = [EXUpdatesBuildData getBuildData:_db scopeKey:scopeKey error:&error];

    XCTAssertTrue([staticBuildData isEqualToDictionary:_configChannelTestDictionary]);
    NSArray<EXUpdatesUpdate *> *allUpdates = [_db allUpdatesWithConfig:_configChannelTest error:&error];
    XCTAssertEqual(allUpdates.count, 1);
    
    XCTAssertNil(error);
  });
}

- (void)test_ensureBuildDataIsConsistent_buildDataIsInconsistent {
  EXUpdatesUpdate *update = [EXUpdatesNewUpdate updateWithNewManifest:_manifest response:nil config:_configChannelTest database:_db];
  
  dispatch_sync(_db.databaseQueue, ^{
    NSError *error;
    [_db addUpdate:update error:&error];

    [EXUpdatesBuildData setBuildData:_db scopeKey:scopeKey config:_configChannelTest error:&error];
    
    [EXUpdatesBuildData ensureBuildDataIsConsistent:_db scopeKey:scopeKey config:_configChannelTestTwo error:&error];
    
    NSDictionary *staticBuildData = [EXUpdatesBuildData getBuildData:_db scopeKey:scopeKey error:&error];
    XCTAssertTrue([staticBuildData isEqualToDictionary:_configChannelTestTwoDictionary]);
    XCTAssertNil(error);
  });
  
  dispatch_sync(_db.databaseQueue, ^{
    NSError *error;
    NSArray<EXUpdatesUpdate *> *allUpdates = [_db allUpdatesWithConfig:_configChannelTestTwo error:&error];
    XCTAssertEqual(allUpdates.count, 0);
  });

}

@end
