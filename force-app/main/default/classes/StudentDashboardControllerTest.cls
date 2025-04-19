/**
 * Test class for StudentDashboardController
 */
@IsTest
private class StudentDashboardControllerTest {
    
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
            new Course__c(Name = 'Data Structures', Course_Code__c = 'CS201', Credits__c = 4)
        };
        insert courses;
        
        // Create test performance records
        List<Performance__c> performances = new List<Performance__c>{
            new Performance__c(Student__c = student.Id, Course__c = courses[0].Id, Grade__c = 'A'),
            new Performance__c(Student__c = student.Id, Course__c = courses[1].Id, Grade__c = 'B+')
        };
        insert performances;
        
        // Create test engagement records
        List<Engagement__c> engagements = new List<Engagement__c>{
            new Engagement__c(
                Student__c = student.Id,
                Type__c = 'Club Participation',
                Date__c = Date.today().addDays(-10),
                Description__c = 'Computer Science Club meeting'
            ),
            new Engagement__c(
                Student__c = student.Id,
                Type__c = 'Tutoring',
                Date__c = Date.today().addDays(-5),
                Description__c = 'Tutoring session for CS101'
            )
        };
        insert engagements;
    }
    
    @IsTest
    static void testGetStudentPerformance() {
        // Get test student
        Student__c student = [SELECT Id FROM Student__c LIMIT 1];
        
        Test.startTest();
        List<StudentDashboardController.PerformanceWrapper> results = 
            StudentDashboardController.getStudentPerformance(student.Id);
        Test.stopTest();
        
        // Verify results
        System.assertEquals(2, results.size(), 'Should return two performance records');
        
        // Verify data
        Set<String> courseNames = new Set<String>();
        for(StudentDashboardController.PerformanceWrapper perf : results) {
            courseNames.add(perf.courseName);
            System.assertNotEquals(null, perf.id, 'ID should not be null');
            System.assertNotEquals(null, perf.grade, 'Grade should not be null');
        }
        
        System.assert(courseNames.contains('Introduction to Programming'), 'Should contain first course');
        System.assert(courseNames.contains('Data Structures'), 'Should contain second course');
    }
    
    @IsTest
    static void testGetStudentEngagement() {
        // Get test student
        Student__c student = [SELECT Id FROM Student__c LIMIT 1];
        
        Test.startTest();
        List<StudentDashboardController.EngagementWrapper> results = 
            StudentDashboardController.getStudentEngagement(student.Id);
        Test.stopTest();
        
        // Verify results
        System.assertEquals(2, results.size(), 'Should return two engagement records');
        
        // Verify data
        Set<String> engagementTypes = new Set<String>();
        for(StudentDashboardController.EngagementWrapper eng : results) {
            engagementTypes.add(eng.type);
            System.assertNotEquals(null, eng.id, 'ID should not be null');
            System.assertNotEquals(null, eng.date, 'Date should not be null');
        }
        
        System.assert(engagementTypes.contains('Club Participation'), 'Should contain club engagement');
        System.assert(engagementTypes.contains('Tutoring'), 'Should contain tutoring engagement');
    }
}