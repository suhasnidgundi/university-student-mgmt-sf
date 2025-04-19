@isTest
private class StudentDashboardControllerTest {
    @isTest
    static void testGetStudentPerformance() {
        // Create test data
        Account university = new Account(
            Name = 'Test University'
        );
        insert university;
        
        Student__c student = new Student__c(
            Name = 'Test Student',
            Email__c = 'test@example.com',
            Department__c = 'Computer Science',
            GPA__c = 3.5,
            Total_Credits__c = 60
        );
        insert student;
        
        // Create test course performance records here
        // (Adjust based on your actual data model)
        
        // Call the method being tested
        Test.startTest();
        List<Object> performance = StudentDashboardController.getStudentPerformance(student.Id);
        Test.stopTest();
        
        // Assert the results
        // (Add appropriate assertions based on expected behavior)
        System.assertNotEquals(null, performance, 'Performance data should not be null');
    }
    
    @isTest
    static void testGetStudentEngagement() {
        // Create test data
        Account university = new Account(
            Name = 'Test University'
        );
        insert university;
        
        Student__c student = new Student__c(
            Name = 'Test Student',
            Email__c = 'test@example.com',
            Department__c = 'Computer Science',
            GPA__c = 3.5,
            Total_Credits__c = 60
        );
        insert student;
        
        // Create test engagement records here
        // (Adjust based on your actual data model)
        
        // Call the method being tested
        Test.startTest();
        List<Object> engagement = StudentDashboardController.getStudentEngagement(student.Id);
        Test.stopTest();
        
        // Assert the results
        // (Add appropriate assertions based on expected behavior)
        System.assertNotEquals(null, engagement, 'Engagement data should not be null');
    }
}