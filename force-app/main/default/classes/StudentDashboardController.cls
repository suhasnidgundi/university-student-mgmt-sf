/**
 * Controller for the Student Dashboard LWC
 */
public with sharing class StudentDashboardController {
    
    /**
     * Get performance data for a student
     * 
     * @param studentId The ID of the student
     * @return List of performance data wrapper objects
     */
    @AuraEnabled(cacheable=true)
    public static List<PerformanceWrapper> getStudentPerformance(Id studentId) {
        List<PerformanceWrapper> performanceData = new List<PerformanceWrapper>();
        
        // Query performance records related to this student
        List<Performance__c> performances = [
            SELECT Id, Course__r.Name, Course__r.Course_Code__c, Grade__c, 
                   Course__r.Credits__c
            FROM Performance__c 
            WHERE Student__c = :studentId
            ORDER BY CreatedDate DESC
        ];
        
        // Convert to wrapper objects
        for(Performance__c perf : performances) {
            PerformanceWrapper wrapper = new PerformanceWrapper();
            wrapper.id = perf.Id;
            wrapper.courseName = perf.Course__r.Name;
            wrapper.courseCode = perf.Course__r.Course_Code__c;
            wrapper.grade = perf.Grade__c;
            wrapper.credits = perf.Course__r.Credits__c;
            
            performanceData.add(wrapper);
        }
        
        return performanceData;
    }
    
    /**
     * Get engagement data for a student
     * 
     * @param studentId The ID of the student
     * @return List of engagement data wrapper objects
     */
    @AuraEnabled(cacheable=true)
    public static List<EngagementWrapper> getStudentEngagement(Id studentId) {
        List<EngagementWrapper> engagementData = new List<EngagementWrapper>();
        
        // Query engagement records related to this student
        List<Engagement__c> engagements = [
            SELECT Id, Type__c, Date__c, Description__c
            FROM Engagement__c 
            WHERE Student__c = :studentId
            ORDER BY Date__c DESC
            LIMIT 10
        ];
        
        // Convert to wrapper objects
        for(Engagement__c eng : engagements) {
            EngagementWrapper wrapper = new EngagementWrapper();
            wrapper.id = eng.Id;
            wrapper.type = eng.Type__c;
            wrapper.date = eng.Date__c;
            wrapper.description = eng.Description__c;
            
            engagementData.add(wrapper);
        }
        
        return engagementData;
    }
    
    /**
     * Wrapper class for performance data
     */
    public class PerformanceWrapper {
        @AuraEnabled public Id id;
        @AuraEnabled public String courseName;
        @AuraEnabled public String courseCode;
        @AuraEnabled public String grade;
        @AuraEnabled public Decimal credits;
    }
    
    /**
     * Wrapper class for engagement data
     */
    public class EngagementWrapper {
        @AuraEnabled public Id id;
        @AuraEnabled public String type;
        @AuraEnabled public Date date;
        @AuraEnabled public String description;
    }
}