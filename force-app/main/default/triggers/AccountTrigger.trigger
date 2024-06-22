/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 06-22-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
trigger AccountTrigger on Account(before insert, after insert) {
  if (Trigger.isBefore) {
    for (Account acct : Trigger.new) {
      if (String.isBlank(acct.Type)) {
        acct.Type = 'Prospect';
      }
      if (
        !String.isBlank(acct.ShippingStreet) &&
        !String.isBlank(acct.ShippingCity) &&
        !String.isBlank(acct.ShippingState) &&
        !String.isBlank(acct.ShippingPostalCode) &&
        !String.isBlank(acct.ShippingCountry)
      ) {
        acct.BillingStreet = acct.ShippingStreet;
        acct.BillingCity = acct.ShippingCity;
        acct.BillingState = acct.ShippingState;
        acct.BillingPostalCode = acct.ShippingPostalCode;
        acct.BillingCountry = acct.ShippingCountry;
      }
      if (
        !String.isBlank(acct.Phone) &&
        !String.isBlank(acct.Website) &&
        !String.isBlank(acct.Fax)
      ) {
        acct.Rating = 'Hot';
      }
    }
  }

  if (Trigger.isAfter) {
    List<Contact> conLst = new List<Contact>();
    for (Account acct : Trigger.new) {
      conLst.add(
        new Contact(
          LastName = 'DefaultContact',
          AccountId = acct.Id,
          Email = 'default@email.com'
        )
      );
    }
    insert conLst;
  }
}
