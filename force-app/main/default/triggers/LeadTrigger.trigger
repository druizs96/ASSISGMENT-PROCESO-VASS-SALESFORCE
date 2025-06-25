trigger LeadTrigger on Lead (before insert, before update) {
    Map<String, Id> nameToCountryId = new Map<String, Id>();
    for (Country__c c : [SELECT Id, Name FROM Country__c]) {
        nameToCountryId.put(c.Name, c.Id);
    }
    for (Lead l : Trigger.new) {
        if (l.Country != null && nameToCountryId.containsKey(l.Country)) {
            l.Country__c = nameToCountryId.get(l.Country);
        } else {
            l.Country__c = null;
        }
    }
}