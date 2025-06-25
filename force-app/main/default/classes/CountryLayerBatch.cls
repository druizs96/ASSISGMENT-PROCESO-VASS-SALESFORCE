global with sharing class CountryLayerBatch implements Database.Batchable<Integer>, Database.AllowsCallouts {
    global Iterable<Integer> start(Database.BatchableContext bc) {
        // Devuelve una lista dummy para forzar la ejecución
        return new List<Integer>{1};
    }
    global void execute(Database.BatchableContext bc, List<Integer> scope) {
        System.debug('Executing CountryLayerBatch...');
        CountryLayerService.callCountryLayerAPI();
    }
    global void finish(Database.BatchableContext bc) {}
}