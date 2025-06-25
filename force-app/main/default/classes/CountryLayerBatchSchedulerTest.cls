@isTest
public class CountryLayerBatchSchedulerTest {
    @isTest
    static void testScheduler() {
        Test.startTest();
        String cron = '0 0 23 * * ?';
        System.schedule('Test CountryLayerBatchScheduler', cron, new CountryLayerBatchScheduler());
        Test.stopTest();
    }
}
