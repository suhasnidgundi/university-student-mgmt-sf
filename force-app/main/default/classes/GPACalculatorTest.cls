/**
 * Test class for GPACalculator
 */
@IsTest
private class GPACalculatorTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test student
        Student__c student = new Student__c(
            Name = 'Test Student',
            Email__c = 'test@example.com',
            Department__c = 'Computer Science'
        );
        insert student;
        
        // Create test courses
        List<Course__c> courses = new List<Course__c>{
            new Course__c(Name = 'Introduction to Programming', Course_Code__c = 'CS101', Credits__c = 3),
            new Course__c(Name = 'Data Structures', Course_Code__c = 'CS201', Credits__c = 4),
            new Course__c(Name = 'Database Systems', Course_Code__c = 'CS301', Credits__c = 3)
        };
        insert courses;
        
        // Create test performance records
        List<Performance__c> performances = new List<Performance__c>{
            new Performance__c(Student__c = student.Id, Course__c = courses[0].Id, Grade__c = 'A'),
            new Performance__c(Student__c = student.Id, Course__c = courses[1].Id, Grade__c = 'B+'),
            new Performance__c(Student__c = student.Id, Course__c = courses[2].Id, Grade__c = 'A-')
        };
        insert performances;
    }
    
    @IsTest
    static void testCalculateGPA() {
        // Get test student
        Student__c student = [SELECT Id FROM Student__c LIMIT 1];
        
        // Call the method to test
        Test.startTest();
        List<GPACalculator.GPAResult> results = GPACalculator.calculateGPA(new List<Id>{student.Id});
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should return one result');
        GPACalculator.GPAResult result = results[0];
        System.assertEquals(student.Id, result.studentId, 'Student ID should match');
        
        // Expected GPA: (3*4.0 + 4*3.3 + 3*3.7) / (3+4+3) = 3.63
        System.assertEquals(3.63, result.gpa, 'GPA should be calculated correctly');
        System.assertEquals(10, result.totalCredits, 'Total credits should be calculated correctly');
    }
    
    @IsTest
    static void testCalculateGPANoPerformance() {
        // Create a student with no performance records
        Student__c student = new Student__c(
            Name = 'New Student',
            Email__c = 'new@example.com',
            Department__c = 'Mathematics'
        );
        insert student;
        
        // Call the method to test
        Test.startTest();
        List<GPACalculator.GPAResult> results = GPACalculator.calculateGPA(new List<Id>{student.Id});
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should return one result');
        GPACalculator.GPAResult result = results[0];
        System.assertEquals(student.Id, result.studentId, 'Student ID should match');
        System.assertEquals(0, result.gpa, 'GPA should be 0 for student with no performance records');
        System.assertEquals(0, result.totalCredits, 'Total credits should be 0');
    }
}