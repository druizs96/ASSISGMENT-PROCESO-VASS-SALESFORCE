@isTest
public class CountryTriggerTest {
    @isTest
    static void testCountryTriggerUpdateName() {
        Country__c c = new Country__c(Name='OldName', alpha2code__c='ON', alpha3code__c='OLD', Capital_city__c='OldCity', region__c='OldRegion');
        insert c;
        Lead l = new Lead(LastName='Test', Company='Test', Country='OldName');
        insert l;
        c.Name = 'NewName';
        update c;
        Lead updatedLead = [SELECT Country__c FROM Lead WHERE Id = :l.Id];
        System.assertEquals(c.Id, updatedLead.Country__c);
    }
}
