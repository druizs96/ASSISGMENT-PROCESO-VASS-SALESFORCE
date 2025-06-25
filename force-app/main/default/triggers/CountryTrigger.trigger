trigger CountryTrigger on Country__c (after insert, after update) {
    Set<String> countryNames = new Set<String>();
    Map<String, Id> nameToCountryId = new Map<String, Id>();
    for (Country__c c : Trigger.new) {
        if (Trigger.isInsert) {
        countryNames.add(c.Name);
        nameToCountryId.put(c.Name, c.Id);
        } else if (Trigger.isUpdate) {
            Country__c oldC = Trigger.oldMap.get(c.Id);
            if (c.Name != oldC.Name) {
                nameToCountryId.put(c.Name, c.Id);
                countryNames.add(c.Name);
                countryNames.add(oldC.Name);
            }
        }
    }
    List<Lead> leadsToUpdate = new List<Lead>();
    for (Lead l : [SELECT Id, Country, Country__c FROM Lead WHERE Country IN :countryNames]) {
        Id newCountryId = nameToCountryId.get(l.Country);
        if (l.Country__c != newCountryId) {
            l.Country__c = newCountryId;
            leadsToUpdate.add(l);
        }
    }
    if (!leadsToUpdate.isEmpty()) {
        update leadsToUpdate;
    }
}