public with sharing class AssetTrackerController {
  @AuraEnabled(cacheable=true)
  public static List<Tracked_Asset__c> getAssets() {
    return [
      SELECT
        Id,
        Name,
        Asset_Name__c,
        Serial_Number__c,
        Status__c,
        Category__c,
        Assigned_To__c,
        Assigned_To__r.Name,
        Purchase_Date__c,
        Purchase_Price__c,
        Location__c
      FROM Tracked_Asset__c
      WITH USER_MODE
      ORDER BY CreatedDate DESC
      LIMIT 500
    ];
  }

  @AuraEnabled(cacheable=true)
  public static Tracked_Asset__c getAsset(Id assetId) {
    List<Tracked_Asset__c> records = [
      SELECT
        Id,
        Name,
        Asset_Name__c,
        Serial_Number__c,
        Status__c,
        Category__c,
        Assigned_To__c,
        Assigned_To__r.Name,
        Purchase_Date__c,
        Purchase_Price__c,
        Location__c
      FROM Tracked_Asset__c
      WHERE Id = :assetId
      WITH USER_MODE
      LIMIT 1
    ];
    return records.isEmpty() ? null : records[0];
  }

  @AuraEnabled
  public static Tracked_Asset__c saveAsset(Tracked_Asset__c asset) {
    if (asset == null) {
      throw new AuraHandledException('No asset record was provided.');
    }
    try {
      Database.upsert(asset, AccessLevel.USER_MODE);
      return getAsset(asset.Id);
    } catch (DmlException e) {
      throw new AuraHandledException(e.getDmlMessage(0));
    }
  }
}
