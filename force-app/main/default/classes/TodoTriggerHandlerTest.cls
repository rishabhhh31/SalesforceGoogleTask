@IsTest
private class TodoTriggerHandlerTest {
    @testSetup
    static void sampleToDos(){
        Test.setMock(HttpCalloutMock.class, new TodoTriggerHandlerTestMock());
        To_Do__c per = new To_Do__c();
        per.Name = 'Personal Task';
        per.Priority__c = 'High';
        per.Due_Date__c = System.now();
        per.Notes__c =  'Personal Task Notes';
        per.Type__c = 'Personal';
        insert per;
    }
    @IsTest
    static void afterInsertTest() {
        Test.startTest();
        To_Do__c td = [SELECT Task_Id__c from To_Do__c LIMIT 1];
        Test.stopTest();
        Assert.isNotNull(td.Task_Id__c,'Task Id is empty');
    }
    
    @IsTest
    static void afterUpdateTest(){
        Test.setMock(HttpCalloutMock.class, new TodoTriggerHandlerTestMock());
        Test.startTest();
        To_Do__c td = [SELECT Task_Id__c from To_Do__c LIMIT 1];
        td.Is_Completed__c = true;
        update td;
        Test.stopTest();
    }
    @IsTest
    static void afterDeleteTest(){
        Test.setMock(HttpCalloutMock.class, new DeleteMockTodoHandler());
        Test.startTest();
        To_Do__c td = [SELECT Task_Id__c from To_Do__c LIMIT 1];
        delete td;
        Test.stopTest();
        List<To_Do__c> toDoList = [SELECT Id from To_Do__c];
        Assert.areEqual(0,toDoList.size());
    }
}