global class TodoTriggerHandlerTestMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
        Map<String,Object> jsonMapBody = new Map<String,Object>();
        jsonMapBody.put('kind','tasks#task');
        jsonMapBody.put('id','T3BuV1BnWFVBTlZWY0kwbA');
        jsonMapBody.put('title','Personal Task');
        jsonMapBody.put('etag','\"MzU3Njc5MTMx\"');
        jsonMapBody.put('updated',System.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
        jsonMapBody.put('selfLink','https://www.googleapis.com/tasks/v1/lists/R2Q0RlpBbndOdDVUQXB2cQ/tasks/T3BuV1BnWFVBTlZWY0kwbA');
        jsonMapBody.put('position','00000000000000000000');
        jsonMapBody.put('notes','Personal Task Notes');
        jsonMapBody.put('status','needsAction');
        jsonMapBody.put('due',System.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
        jsonMapBody.put('webViewLink','https://tasks.google.com/task/OpnWPgXUANVVcI0l');
        List<String> linkList = new List<String>();
        jsonMapBody.put('links',linkList);
        String responseBody = JSON.serialize(jsonMapBody,true);
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(responseBody);
        res.setStatusCode(200);
        return res;
    }
}