public class GoogleTasksJSON {
    public String kind;
    public String id;
    public String etag;
    public String title;
    public String updated;
    public String selfLink;
    public String parent;
    public String position;
    public String notes;
    public String status;
    public String due;
    public String completed;
    public Boolean deleted;
    public Boolean hidden;
    public List<Links> links;
    public class Links {
        public String type;
        public String description;
        public String link;
    }   
    public String webViewLink;
    
    public static GoogleTasksJSON parse(String json) {
        return (GoogleTasksJSON) System.JSON.deserialize(json, GoogleTasksJSON.class);
    }   
}