public class ToDoHandler {
    public class Filter{
        @AuraEnabled
        public String searchKey {set;get;}
        @AuraEnabled
        public String sortBy {set;get;}
        @AuraEnabled
        public List<String> priorities {set;get;}
        @AuraEnabled
        public List<String> types {set;get;}
    }
    @AuraEnabled(cacheable=true)
    public static List<To_Do__c> getTodoData(Filter filters){
        String orderBy = '';
        String whereClause = '';
        List<String> criteria = new List<String>();
        if(!String.isEmpty(filters.searchKey)){
            String key = '%'+filters.searchKey+'%';
            criteria.add('Name LIKE : key');
        }
        if(filters.priorities != null){
            List<String> priorities = filters.priorities;
            criteria.add('Priority__c IN : priorities');
        }
        if(filters.types != null){
            List<String> types = filters.types;
            criteria.add('Type__c IN : types');
        }
        if(!String.isEmpty(filters.sortBy)){
            String sortBy = filters.sortBy;
            orderBy = ' ORDER BY '+sortBy;
        }
        
        if(criteria.size()>0){
            whereClause = 'WHERE '+String.join(criteria,' AND ');
        }
        return Database.query('SELECT Name, Is_Completed__c, Priority__c, Due_Date__c, Notes__c, Task_Id__c, Type__c FROM To_Do__c '+whereClause+orderBy);
    }
}