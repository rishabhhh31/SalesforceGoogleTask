@IsTest
private class ToDoHandlerTest {
    @TestSetup
    static void testData(){
        Test.setMock(HttpCalloutMock.class, new TodoTriggerHandlerTestMock());
        List<To_Do__c> toDoList = new List<To_Do__c>();
        toDoList.add(new To_Do__c(
            Name = 'Complete Project Report',
            Due_Date__c = DateTime.newInstance(2024, 6, 20, 17, 0, 0),
            Notes__c = 'Prepare the final report for the project.',
            Priority__c = 'High',
            Type__c = 'Work'
        ));
        
        toDoList.add(new To_Do__c(
            Name = 'Grocery Shopping',
            Due_Date__c = DateTime.newInstance(2024, 6, 15, 10, 0, 0),
            Notes__c = 'Buy vegetables, fruits, and dairy products.',
            Priority__c = 'Medium',
            Type__c = 'Household'
        ));
        
        toDoList.add(new To_Do__c(
            Name = 'Math Assignment',
            Due_Date__c = DateTime.newInstance(2024, 6, 18, 22, 0, 0),
            Notes__c = 'Complete the calculus problems from chapter 5.',
            Priority__c = 'High',
            Type__c = 'Academic'
        ));
        
        toDoList.add(new To_Do__c(
            Name = 'Team Meeting Preparation',
            Due_Date__c = DateTime.newInstance(2024, 6, 16, 14, 0, 0),
            Notes__c = 'Prepare the agenda and presentation slides.',
            Priority__c = 'High',
            Type__c = 'Office'
        ));
        
        toDoList.add(new To_Do__c(
            Name = 'Yoga Session',
            Due_Date__c = DateTime.newInstance(2024, 6, 14, 7, 0, 0),
            Notes__c = 'Attend the morning yoga class.',
            Priority__c = 'Low',
            Type__c = 'Personal'
        ));
        insert toDoList;
        
    }
    @IsTest
    static void testFilterCriterias(){
        String searchKey = 'Yog';
        List<String> priorities = new List<String>{'Low','High'};
        List<String> types = new List<String>{'Personal','Office'};
        String sortBy = 'Name ASC';
        ToDoHandler.Filter newFilt = new ToDoHandler.Filter();
        newFilt.types = types;
        newFilt.priorities = priorities;
        newFilt.sortBy = sortBy;
        newFilt.searchKey = searchKey;
        
        Test.startTest();
        List<To_Do__c> todoList = ToDoHandler.getTodoData(newFilt);
        Test.stopTest();
        Assert.isTrue(todoList.size() > 0, 'List is expecting to return some data.');
    }
}