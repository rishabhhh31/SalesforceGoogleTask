public class TodoTriggerHandler extends TriggerHandler {
    protected override void afterInsert() {
        insertGoogleTasks(getRecordIds(Trigger.new)); 
    }
    protected override void afterUpdate() {
        sObject todo = Trigger.old[0];
        if(todo instanceof To_Do__c && ((To_Do__c)todo).Task_Id__c != null){
            updateGoogleTasks(getRecordIds(Trigger.new));
        }
    }
    protected override void afterDelete(){
        Map<String,String> googleTaskMap = new Map<String,String>();
        for(Sobject sobj : Trigger.old){
            To_Do__c todo = (To_Do__c)sobj;
            googleTaskMap.put(todo.Task_Id__c,todo.Type__c);
        }
        if(!googleTaskMap.isEmpty()){
            deleteGoogleTasks(googleTaskMap);
        }
    }
    public List<Id> getRecordIds(List<To_Do__c> toDoRecords){
        List<Id> recordIds = new List<Id>();
        for(To_Do__c todo : toDoRecords){
            recordIds.add(todo.Id);
        }
        return recordIds;
    }
    @future(callout=true)
    public static void insertGoogleTasks(List<Id> taskIds){
        List<To_Do__c> taskRecords = [SELECT Id, Type__c, Due_Date__c, Is_Completed__c, Notes__c, Name from To_Do__c WHERE Id IN: taskIds];
        for(To_Do__c todo : taskRecords){
            HttpRequest request = getHttpRequest(todo, TriggerOperation.AFTER_INSERT);
            Http h = new Http();
            HttpResponse response = h.send(request);
            GoogleTasksJSON jsonResponse = GoogleTasksJSON.parse(response.getBody());
            if(response.getStatusCode()==200){
                todo.Task_Id__c = jsonResponse.id;
            }
        }
        Database.SaveResult[] result = Database.update(taskRecords,false);
        for(Database.SaveResult res : result){
            if(res.isSuccess()){
                System.debug('Task Created Successfully');
            }else{
                for(Database.Error err : res.getErrors()){
                    System.debug(err.getMessage());
                }
            }
        }
    }
    @future(callout=true)
    public static void updateGoogleTasks(List<Id> taskIds){
        List<To_Do__c> taskRecords = [SELECT Id, Type__c, Due_Date__c, Task_Id__c, Is_Completed__c, Notes__c, Name from To_Do__c WHERE Id IN: taskIds];
        for(To_Do__c todo : taskRecords){
            HttpRequest request = getHttpRequest(todo, TriggerOperation.AFTER_UPDATE);
            Http h = new Http();
            HttpResponse response = h.send(request);
            if(response.getStatusCode()==200){
                System.debug('Task is updated');
            }else{
                System.debug('Task is not updated');
            }
        }
    }
    @future(callout=true)
    public static void deleteGoogleTasks(Map<String,String> googleTaskMap){
        for(String taskId : googleTaskMap.keySet()){
            String taskListId = getTaskListId(googleTaskMap.get(taskId));
            HttpRequest request = new HttpRequest();
            request.setMethod('DELETE');
            request.setTimeout(12000);
            request.setEndpoint('callout:GoogleTaskNamedCredentials/tasks/v1/lists/'+taskListId+'/tasks/'+taskId);
            Http h = new Http();
            HttpResponse response = h.send(request);
            if(response.getStatusCode()==204){
                System.debug('Task Deleted Successfully');
            }else {
                String responseBody = response.getBody();
                System.debug('Error occured in deleting the Google Task in the callout: ');
                System.debug(responseBody);
            }
        }
    }
    public static HttpRequest getHttpRequest(To_Do__c task, TriggerOperation operation){
        HttpRequest request = new HttpRequest();
        if(operation == TriggerOperation.AFTER_INSERT || operation == TriggerOperation.AFTER_UPDATE){
            GoogleTasksJSON jsonBody = new GoogleTasksJSON();
            jsonBody.title = task.Name;
            jsonBody.notes = task.Notes__c;
            jsonBody.status = task.Is_Completed__c?'completed':'needsAction';
            jsonBody.due = task.Due_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            jsonBody.deleted = false;
            jsonBody.hidden = false;
            String reqBody = JSON.serialize(jsonBody,true);
            request.setBody(reqBody); 
        }
        String taskListId = getTaskListId(task.Type__c);
        if(operation == TriggerOperation.AFTER_INSERT){
            request.setEndpoint('callout:GoogleTaskNamedCredentials/tasks/v1/lists/'+taskListId+'/tasks');
            request.setMethod('POST');
        }
        else if(operation == TriggerOperation.AFTER_UPDATE){
            request.setEndpoint('callout:GoogleTaskNamedCredentials/tasks/v1/lists/'+taskListId+'/tasks/'+task.Task_Id__c);
            request.setMethod('PATCH');
        }
        request.setHeader('Content-Type','application/json');
        request.setHeader('Accept', 'application/json');
        request.setTimeout(12000);
        return request;
    }
    public static String getTaskListId(String taskType){
        String taskListId;
        switch on taskType{
            when 'Personal'{
                taskListId = 'MDk4Mjc3NDUxNTUwOTU2MTMwMTE6MDow';
            }
            when 'Office'{
                taskListId = 'LWtfa3ZJcjctRlZuN0tiMg';
            }
            when 'Academic'{
                taskListId = 'LS1YV1hRZEhiNXhuWHZrWg';
            }
            when 'Work'{
                taskListId = 'eThGM3V4ZC1aV2pyWHJhNg';
            }
            when 'Household'{
                taskListId = 'R2Q0RlpBbndOdDVUQXB2cQ';
            }
        }
        return taskListId;
    }
}