/**
 * @description       :
 * @author            : Adrienne D. Millican
 * @group             :
 * @last modified on  : 06-22-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/

trigger OpportunityTrigger on Opportunity(
  before update,
  after update,
  after delete
) {
  if (Trigger.isBefore) {
    if (Trigger.isUpdate && !TriggerHandler.hasRunBeforeUpdate) {
      TriggerHandler.hasRunBeforeUpdate = true;
      for (Opportunity opp : Trigger.newMap.values()) {
        if (opp.Amount <= 5000) {
          opp.addError('Opportunity amount must be greater than 5000');
        }
      }
    }
  }

  if (Trigger.isAfter) {
    if (Trigger.isUpdate && !TriggerHandler.hasRunAfterUpdate) {
      TriggerHandler.hasRunAfterUpdate = true;
      Set<Id> acctIdSet = new Set<Id>();
      List<Opportunity> oppsToUpdLst = new List<Opportunity>();
      for (Opportunity opp : Trigger.newMap.values()) {
        if (opp.AccountId != null) {
          acctIdSet.add(opp.AccountId);
        }
      }
      List<Contact> contactsOnAcctLst = [
        SELECT Id, AccountId
        FROM Contact
        WHERE AccountId IN :acctIdSet AND Title = 'CEO'
      ];

      for (Opportunity opp : [
        SELECT Id, AccountId
        FROM Opportunity
        WHERE Id IN :Trigger.newMap.keyset()
      ]) {
        for (Contact con : contactsOnAcctLst) {
          if (con.AccountId.equals(opp.AccountId)) {
            opp.Primary_Contact__c = con.Id;
            oppsToUpdLst.add(opp);
            break;
          }
        }
      }
      if (oppsToUpdLst.size() > 0) {
        update oppsToUpdLst;
      }
    }
    if (Trigger.isDelete) {
      Set<Id> acctIdSet = new Set<Id>();
      for (Opportunity opp : Trigger.oldMap.values()) {
        if (opp.StageName.equals('Closed Won') && opp.AccountId != null) {
          acctIdSet.add(opp.AccountId);
        }
      }
      Map<Id, Account> acctsWithIndustry = new Map<Id, Account>(
        [
          SELECT Id
          FROM Account
          WHERE Id IN :acctIdSet AND Industry = 'Banking'
        ]
      );
      for (Opportunity opp : Trigger.oldMap.values()) {
        if (
          opp.StageName.equals('Closed Won') &&
          acctsWithIndustry.keySet().contains(opp.AccountId)
        ) {
          opp.addError(
            'Cannot delete closed opportunity for a banking account that is won'
          );
        }
      }
    }
  }
}
