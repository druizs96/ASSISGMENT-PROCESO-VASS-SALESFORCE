public with sharing class CountryLayerService {

    private static final String COUNTRY_LAYER_API_KEY = 'd31d74898f9326eecce0bf0908bf2019';

    @InvocableMethod
    public static void callCountryLayerAPI() {
        String url = 'https://api.countrylayer.com/v2/all?access_key=' + COUNTRY_LAYER_API_KEY;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');

        HttpResponse res = new HttpResponse();
        Http http = new Http();
        if (Test.isRunningTest()) {
            MockCallOut mock = new MockCallout();
            res = mock.respond(req);
        } else {
            res = http.send(req);
        }

        if (res.getStatusCode() == 200) {
            String responseBody = res.getBody();
            syncCountriesFromJson(responseBody);
        } else {
            System.debug('Error: ' + res.getStatusCode() + ' - ' + res.getBody());
        }
    }

    public static void syncCountriesFromJson(String jsonResponse) {
        List<Object> rawCountries = (List<Object>) JSON.deserializeUntyped(jsonResponse);
        List<Map<String, Object>> countries = new List<Map<String, Object>>();
        for (Object o : rawCountries) {
            countries.add((Map<String, Object>) o);
        }

        Set<String> names = new Set<String>();
        for (Map<String, Object> c : countries) {
            names.add((String)c.get('name'));
        }
        Map<String, Country__c> existingCountries = new Map<String, Country__c>();
        for (Country__c c : [SELECT Id, Name, alpha2code__c, alpha3code__c, Capital_city__c, region__c, regionalBlocs__c FROM Country__c]) {
            existingCountries.put(c.Name, c);
        }

        List<Country__c> toInsert = new List<Country__c>();
        List<Country__c> toUpdate = new List<Country__c>();
        List<Country__c> toDelete = new List<Country__c>();

        for (Map<String, Object> c : countries) {
            String name = (String)c.get('name');
            String alpha2 = (String)c.get('alpha2Code');
            String alpha3 = (String)c.get('alpha3Code');
            String capital = (String)c.get('capital');
            String region = (String)c.get('region');
            String regionalBlocs = '';
            if (c.containsKey('regionalBlocs')) {
                List<Object> blocs = (List<Object>)c.get('regionalBlocs');
                List<String> acronyms = new List<String>();
                for (Object bloc : blocs) {
                    Map<String, Object> blocMap = (Map<String, Object>)bloc;
                    if (blocMap.containsKey('acronym')) {
                        acronyms.add((String)blocMap.get('acronym'));
                    }
                }
                regionalBlocs = String.join(acronyms, '; ');
            }

            if (existingCountries.containsKey(name)) {
                Country__c existing = existingCountries.get(name);
                Boolean changed = false;
                if (existing.alpha2code__c != alpha2) { existing.alpha2code__c = alpha2; changed = true; }
                if (existing.alpha3code__c != alpha3) { existing.alpha3code__c = alpha3; changed = true; }
                if (existing.Capital_city__c != capital) { existing.Capital_city__c = capital; changed = true; }
                if (existing.region__c != region) { existing.region__c = region; changed = true; }
                if (existing.regionalBlocs__c != regionalBlocs) { existing.regionalBlocs__c = regionalBlocs; changed = true; }
                if (changed) toUpdate.add(existing);
                existingCountries.remove(name);
            } else {
                Country__c newCountry = new Country__c(
                    Name = name,
                    alpha2code__c = alpha2,
                    alpha3code__c = alpha3,
                    Capital_city__c = capital,
                    region__c = region,
                    regionalBlocs__c = regionalBlocs
                );
                toInsert.add(newCountry);
            }
        }

        toDelete.addAll(existingCountries.values());

        if (!toInsert.isEmpty()) insert toInsert;
        if (!toUpdate.isEmpty()) update toUpdate;
        if (!toDelete.isEmpty()) delete toDelete;
    }

    

    /**
     * @description MockCallout to simulate response when test classes is running.
     */
    public class MockCallout implements HttpCalloutMock {
        /**
         * @description Mock HTTP response
         * @return HTTP response with valid status code
         * @param  request HTTP mock request
         */
        public HttpResponse respond(HttpRequest request) {
            HttpResponse res = new HttpResponse();
            res.setBody('[{"name":"Germany","topLevelDomain":[".de"],"alpha2Code":"DE","alpha3Code":"DEU","callingCodes":["49"],"capital":"Berlin","altSpellings":["DE","Federal Republic of Germany","Bundesrepublik Deutschland"],"region":"Europe","subregion":"Western Europe","population":81770900,"latlng":[51,9],"demonym":"German","area":357114,"gini":28.3,"timezones":["UTC+01:00"],"borders":["AUT","BEL","CZE","DNK","FRA","LUX","NLD","POL","CHE"],"nativeName":"Deutschland","numericCode":"276","currencies":[{"code":"EUR","name":"Euro","symbol":"€"}],"languages":[{"iso639_1":"de","iso639_2":"deu","name":"German","nativeName":"Deutsch"}],"translations":{"br":"Alemanha","de":"Deutschland","es":"Alemania","fa":"آلمان","fr":"Allemagne","hr":"Njemačka","it":"Germania","ja":"ドイツ","nl":"Duitsland","pt":"Alemanha"},"flag":"https://restcountries.eu/data/deu.svg","regionalBlocs":[{"acronym":"EU","name":"European Union"}],"cioc":"GER"}]');
            res.setStatusCode(200);
            return res;
        }
    }

}