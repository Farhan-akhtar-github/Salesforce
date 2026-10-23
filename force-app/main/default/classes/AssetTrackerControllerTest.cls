@IsTest
private class AssetTrackerControllerTest {
  private static List<Tracked_Asset__c> buildAssets(Integer count) {
    List<Tracked_Asset__c> assets = new List<Tracked_Asset__c>();
    for (Integer i = 0; i < count; i++) {
      assets.add(
        new Tracked_Asset__c(
          Asset_Name__c = 'Asset ' + i,
          Serial_Number__c = 'SN-' + i,
          Status__c = 'Available',
          Category__c = 'Laptop',
          Location__c = 'HQ'
        )
      );
    }
    return assets;
  }

  @TestSetup
  static void setup() {
    insert buildAssets(5);
  }

  @IsTest
  static void getAssetsReturnsRecords() {
    Test.startTest();
    List<Tracked_Asset__c> result = AssetTrackerController.getAssets();
    Test.stopTest();
    Assert.areEqual(
      5,
      result.size(),
      'Expected all seeded assets to be returned.'
    );
  }

  @IsTest
  static void getAssetReturnsSingleRecord() {
    Tracked_Asset__c seeded = [SELECT Id FROM Tracked_Asset__c LIMIT 1];
    Test.startTest();
    Tracked_Asset__c result = AssetTrackerController.getAsset(seeded.Id);
    Test.stopTest();
    Assert.areEqual(seeded.Id, result.Id, 'Should return the requested asset.');
  }

  @IsTest
  static void saveAssetInsertsNewRecord() {
    Tracked_Asset__c asset = new Tracked_Asset__c(
      Asset_Name__c = 'New Laptop',
      Serial_Number__c = 'SN-NEW',
      Status__c = 'Available',
      Category__c = 'Laptop'
    );
    Test.startTest();
    Tracked_Asset__c saved = AssetTrackerController.saveAsset(asset);
    Test.stopTest();
    Assert.isNotNull(saved.Id, 'Inserted asset should have an Id.');
    Assert.areEqual('New Laptop', saved.Asset_Name__c, 'Name should persist.');
  }

  @IsTest
  static void saveAssetUpdatesExistingRecord() {
    Tracked_Asset__c seeded = [
      SELECT Id, Asset_Name__c
      FROM Tracked_Asset__c
      LIMIT 1
    ];
    seeded.Status__c = 'In Repair';
    Test.startTest();
    Tracked_Asset__c saved = AssetTrackerController.saveAsset(seeded);
    Test.stopTest();
    Assert.areEqual(
      'In Repair',
      saved.Status__c,
      'Status update should persist.'
    );
  }

  @IsTest
  static void saveAssetNullThrows() {
    Boolean threw = false;
    Test.startTest();
    try {
      AssetTrackerController.saveAsset(null);
    } catch (AuraHandledException e) {
      threw = true;
    }
    Test.stopTest();
    Assert.isTrue(
      threw,
      'Saving a null asset should raise an AuraHandledException.'
    );
  }

  @IsTest
  static void validationRuleBlocksInUseWithoutAssignee() {
    Tracked_Asset__c asset = new Tracked_Asset__c(
      Asset_Name__c = 'Unassigned In Use',
      Status__c = 'In Use'
    );
    Boolean threw = false;
    Test.startTest();
    try {
      AssetTrackerController.saveAsset(asset);
    } catch (AuraHandledException e) {
      threw = true;
    }
    Test.stopTest();
    Assert.isTrue(threw, 'In Use without an assignee should be rejected.');
  }
}
