@isTest
public class CountryLayerServiceTest {
    @isTest
    static void testSyncCountriesFromJson_insert_update_delete() {
        // Datos iniciales en Salesforce
        Country__c c1 = new Country__c(Name='Spain', alpha2code__c='ES', alpha3code__c='ESP', Capital_city__c='Madrid', region__c='Europe', regionalBlocs__c='EU');
        Country__c c2 = new Country__c(Name='France', alpha2code__c='FR', alpha3code__c='FRA', Capital_city__c='Paris', region__c='Europe', regionalBlocs__c='EU');
        insert new List<Country__c>{c1, c2};

        // JSON simula que solo existe Spain y se actualiza, y entra uno nuevo (Germany)
        String json = '[{"name":"Spain","alpha2Code":"ES","alpha3Code":"ESP","capital":"Madrid","region":"Europe","regionalBlocs":[{"acronym":"EU"}]},'+
                      '{"name":"Germany","alpha2Code":"DE","alpha3Code":"DEU","capital":"Berlin","region":"Europe","regionalBlocs":[{"acronym":"EU"}]}]';
        Test.startTest();
        CountryLayerService.syncCountriesFromJson(json);
        Test.stopTest();

        // Spain debe existir y Germany también, France debe haberse borrado
        Map<String, Country__c> countries = new Map<String, Country__c>();
        for(Country__c c : [SELECT Name FROM Country__c]) countries.put(c.Name, c);
        System.assert(countries.containsKey('Spain'));
        System.assert(countries.containsKey('Germany'));
        System.assert(!countries.containsKey('France'));
    }

    @isTest
    static void testCallCountryLayerAPI_mock() {
        // Simula un callout
        Test.startTest();
        CountryLayerService_Mock.setMockResponse();
        CountryLayerService.callCountryLayerAPI();
        Test.stopTest();
        // No asserts, solo cobertura
    }
}

@isTest
global class CountryLayerService_Mock implements HttpCalloutMock {
    global static void setMockResponse() {
        Test.setMock(HttpCalloutMock.class, new CountryLayerService_Mock());
    }
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('[{"name":"Testland","alpha2Code":"TL","alpha3Code":"TST","capital":"Test City","region":"Test Region","regionalBlocs":[{"acronym":"TST"}]}]');
        res.setStatusCode(200);
        return res;
    }
}
