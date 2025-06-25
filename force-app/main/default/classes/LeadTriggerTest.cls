@isTest
public class LeadTriggerTest {
    @isTest
    static void testLeadTriggerInsertAndUpdate() {
        Country__c c = new Country__c(Name='TestCountry', alpha2code__c='TC', alpha3code__c='TCO', Capital_city__c='TestCity', region__c='TestRegion');
        insert c;
        Lead l = new Lead(LastName='Test', Company='Test', Country='TestCountry');
        insert l;
        Lead inserted = [SELECT Country__c FROM Lead WHERE Id = :l.Id];
        System.assertEquals(c.Id, inserted.Country__c);
        // Update country
        l.Country = 'TestCountry';
        update l;
        Lead updated = [SELECT Country__c FROM Lead WHERE Id = :l.Id];
        System.assertEquals(c.Id, updated.Country__c);
    }
}
