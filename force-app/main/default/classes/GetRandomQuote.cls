public with sharing class GetRandomQuote {
    @AuraEnabled
    public static String getQuote() {
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.quotable.io/quotes/random?tags=motivational');
        request.setMethod('GET');
        request.setHeader('accept','application/json');
        Http http = new Http();
        HttpResponse response = http.send(request);
        if(response.getStatusCode()==200){
            return response.getBody();
        }
        return null;
    }
}