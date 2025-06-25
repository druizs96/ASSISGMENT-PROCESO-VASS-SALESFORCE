global with sharing class CountryLayerBatchScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new CountryLayerBatch(), 1);
    }
}