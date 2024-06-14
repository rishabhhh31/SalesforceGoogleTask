Trigger ToDoTrigger on To_Do__c (after insert, after update, after delete) {
    TodoTriggerHandler handler = new TodoTriggerHandler();
    handler.run();
}