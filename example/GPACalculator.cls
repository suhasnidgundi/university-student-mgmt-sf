/**
 * GPACalculator - Invocable Apex class for calculating student GPA
 * 
 * @author Your Name
 * @version 1.0
 */
public with sharing class GPACalculator {
    
    /**
     * Calculates GPA for a given student based on their performance records
     * @param studentIds List of Student Ids to calculate GPA for
     * @return List of calculated GPA results
     */
    @InvocableMethod(label='Calculate Student GPA' description='Calculates GPA for a student based on performance records')
    public static List<GPAResult> calculateGPA(List<Id> studentIds) {
        List<GPAResult> results = new List<GPAResult>();
        
        // Get all performance records for these students
        List<Performance__c> performances = [
            SELECT Id, Student__c, Course__c, Grade__c, Course__r.Credits__c 
            FROM Performance__c 
            WHERE Student__c IN :studentIds
        ];
        
        // Group performances by student
        Map<Id, List<Performance__c>> studentPerformances = new Map<Id, List<Performance__c>>();
        for(Performance__c perf : performances) {
            if(!studentPerformances.containsKey(perf.Student__c)) {
                studentPerformances.put(perf.Student__c, new List<Performance__c>());
            }
            studentPerformances.get(perf.Student__c).add(perf);
        }
        
        // Calculate GPA for each student
        for(Id studentId : studentIds) {
            Decimal totalGradePoints = 0;
            Decimal totalCredits = 0;
            Decimal gpa = 0;
            
            // Check if there are performance records for this student
            if(studentPerformances.containsKey(studentId)) {
                for(Performance__c perf : studentPerformances.get(studentId)) {
                    // Convert letter grade to grade points
                    Decimal gradePoints = convertGradeToPoints(perf.Grade__c);
                    Decimal credits = perf.Course__r.Credits__c != null ? perf.Course__r.Credits__c : 0;
                    
                    totalGradePoints += gradePoints * credits;
                    totalCredits += credits;
                }
                
                // Calculate GPA
                if(totalCredits > 0) {
                    gpa = totalGradePoints / totalCredits;
                }
            }
            
            // Create GPA result
            GPAResult result = new GPAResult();
            result.studentId = studentId;
            result.gpa = gpa.setScale(2);
            result.totalCredits = totalCredits.intValue();
            results.add(result);
        }
        
        return results;
    }
    
    /**
     * Converts a letter grade to numeric grade points
     * @param grade Letter grade (A, B, C, etc.)
     * @return Numeric grade points
     */
    private static Decimal convertGradeToPoints(String grade) {
        if(grade == null) return 0;
        
        switch on grade.toUpperCase() {
            when 'A+' {
                return 4.0;
            }
            when 'A' {
                return 4.0;
            }
            when 'A-' {
                return 3.7;
            }
            when 'B+' {
                return 3.3;
            }
            when 'B' {
                return 3.0;
            }
            when 'B-' {
                return 2.7;
            }
            when 'C+' {
                return 2.3;
            }
            when 'C' {
                return 2.0;
            }
            when 'C-' {
                return 1.7;
            }
            when 'D+' {
                return 1.3;
            }
            when 'D' {
                return 1.0;
            }
            when 'F' {
                return 0.0;
            }
            when else {
                return 0.0;
            }
        }
    }
    
    /**
     * Result class for the invocable method
     */
    public class GPAResult {
        @InvocableVariable(label='Student ID' description='ID of the student' required=true)
        public Id studentId;
        
        @InvocableVariable(label='GPA' description='Calculated GPA')
        public Decimal gpa;
        
        @InvocableVariable(label='Total Credits' description='Total credits completed')
        public Integer totalCredits;
    }
}