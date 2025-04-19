import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import getStudentPerformance from '@salesforce/apex/StudentDashboardController.getStudentPerformance';
import getStudentEngagement from '@salesforce/apex/StudentDashboardController.getStudentEngagement';

// Import Student fields
import STUDENT_NAME_FIELD from '@salesforce/schema/Student__c.Name';
import STUDENT_EMAIL_FIELD from '@salesforce/schema/Student__c.Email__c';
import STUDENT_DEPARTMENT_FIELD from '@salesforce/schema/Student__c.Department__c';
import STUDENT_GPA_FIELD from '@salesforce/schema/Student__c.GPA__c';
import STUDENT_CREDITS_FIELD from '@salesforce/schema/Student__c.Total_Credits__c';

const FIELDS = [
    STUDENT_NAME_FIELD,
    STUDENT_EMAIL_FIELD,
    STUDENT_DEPARTMENT_FIELD,
    STUDENT_GPA_FIELD,
    STUDENT_CREDITS_FIELD
];

export default class StudentDashboard extends LightningElement {
    @api recordId; // The ID of the current student record
    @track performanceData = [];
    @track engagementData = [];
    @track error;
    @track chartConfig = {};
    @track isLoading = true;

    wiredStudentResult;
    wiredPerformanceResult;
    wiredEngagementResult;

    // Wire the student record
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredStudent(result) {
        this.wiredStudentResult = result;
        if (result.data) {
            this.error = undefined;
            this.prepareChartData();
        } else if (result.error) {
            this.error = result.error;
        }
    }

    // Wire the performance data
    @wire(getStudentPerformance, { studentId: '$recordId' })
    wiredPerformance(result) {
        this.wiredPerformanceResult = result;
        if (result.data) {
            this.performanceData = result.data;
            this.error = undefined;
            this.prepareChartData();
        } else if (result.error) {
            this.error = result.error;
        }
    }

    // Wire the engagement data
    @wire(getStudentEngagement, { studentId: '$recordId' })
    wiredEngagement(result) {
        this.wiredEngagementResult = result;
        if (result.data) {
            this.engagementData = result.data;
            this.error = undefined;
            this.prepareChartData();
        } else if (result.error) {
            this.error = result.error;
        }
    }

    // Getters for student fields
    get studentName() {
        return this.wiredStudentResult.data ?
            getFieldValue(this.wiredStudentResult.data, STUDENT_NAME_FIELD) : '';
    }

    get studentEmail() {
        return this.wiredStudentResult.data ?
            getFieldValue(this.wiredStudentResult.data, STUDENT_EMAIL_FIELD) : '';
    }

    get studentDepartment() {
        return this.wiredStudentResult.data ?
            getFieldValue(this.wiredStudentResult.data, STUDENT_DEPARTMENT_FIELD) : '';
    }

    get studentGpa() {
        return this.wiredStudentResult.data ?
            getFieldValue(this.wiredStudentResult.data, STUDENT_GPA_FIELD) : '';
    }

    get studentTotalCredits() {
        return this.wiredStudentResult.data ?
            getFieldValue(this.wiredStudentResult.data, STUDENT_CREDITS_FIELD) : '';
    }

    get hasPerformanceData() {
        return this.performanceData && this.performanceData.length > 0;
    }

    get hasEngagementData() {
        return this.engagementData && this.engagementData.length > 0;
    }

    // Prepare chart data
    prepareChartData() {
        if (this.performanceData.length > 0) {
            // Prepare data for the performance chart
            const labels = this.performanceData.map(item => item.courseName);
            const gradePoints = this.performanceData.map(item => this.convertGradeToPoints(item.grade));

            this.chartConfig = {
                type: 'bar',
                data: {
                    labels: labels,
                    datasets: [{
                        label: 'Performance by Course',
                        data: gradePoints,
                        backgroundColor: 'rgba(54, 162, 235, 0.5)',
                        borderColor: 'rgba(54, 162, 235, 1)',
                        borderWidth: 1
                    }]
                },
                options: {
                    scales: {
                        y: {
                            beginAtZero: true,
                            max: 4
                        }
                    }
                }
            };
        }

        this.isLoading = false;
    }

    // Convert letter grade to numeric grade points for chart display
    convertGradeToPoints(grade) {
        if (!grade) return 0;

        const gradeMap = {
            'A+': 4.0, 'A': 4.0, 'A-': 3.7,
            'B+': 3.3, 'B': 3.0, 'B-': 2.7,
            'C+': 2.3, 'C': 2.0, 'C-': 1.7,
            'D+': 1.3, 'D': 1.0, 'F': 0.0
        };

        return gradeMap[grade] || 0;
    }

    // Method to refresh the data
    handleRefresh() {
        this.isLoading = true;

        Promise.all([
            refreshApex(this.wiredStudentResult),
            refreshApex(this.wiredPerformanceResult),
            refreshApex(this.wiredEngagementResult)
        ]).then(() => {
            this.isLoading = false;
        }).catch(error => {
            this.error = error;
            this.isLoading = false;
        });
    }
}