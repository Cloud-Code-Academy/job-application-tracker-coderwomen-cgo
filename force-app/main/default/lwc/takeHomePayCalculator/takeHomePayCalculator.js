import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

import SALARY_FIELD from '@salesforce/schema/Job_Application__c.Salary__c';
import FEDERAL_TAX_FIELD from '@salesforce/schema/Job_Application__c.Federal_Income_Tax__c';
import MEDICARE_FIELD from '@salesforce/schema/Job_Application__c.Medicare_Withholding__c';
import SOCIALSECURITY_FIELD from '@salesforce/schema/Job_Application__c.Social_Security__c';
import YEARLY_PAY_FIELD from '@salesforce/schema/Job_Application__c.Yearly_Take_home_Pay__c';
import BI_ANNUAL_PAY_FIELD from '@salesforce/schema/Job_Application__c.Bi_annual_Pay__c';
import MONTHLY_PAY_FIELD from '@salesforce/schema/Job_Application__c.Monthly_Take_home_Pay__c';
import BI_WEEKLY_PAY_FIELD from '@salesforce/schema/Job_Application__c.Bi_weekly_Pay__c';

export default class JobAppSummary extends LightningElement {
    @api recordId;

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [
            SALARY_FIELD,
            FEDERAL_TAX_FIELD,
            MEDICARE_FIELD,
            SOCIALSECURITY_FIELD,
            YEARLY_PAY_FIELD,
            BI_ANNUAL_PAY_FIELD,
            MONTHLY_PAY_FIELD,
            BI_WEEKLY_PAY_FIELD
        ]
    }) jobAppRecord;

    get hasData() {
        return this.jobAppRecord && this.jobAppRecord.data;
    }

    // Left column
    get formattedSalary() {
        return this.formatCurrency(this.jobAppRecord?.data?.fields?.Salary__c?.value);
    }

    get formattedFederalTax() {
        return this.formatCurrency(this.jobAppRecord?.data?.fields?.Federal_Income_Tax__c?.value);
    }

    get formattedMedicare() {
        return this.formatCurrency(this.jobAppRecord?.data?.fields?.Medicare_Withholding__c?.value);
    }

    get formattedSocialSecurity() {
        return this.formatCurrency(this.jobAppRecord?.data?.fields?.Social_Security__c?.value);
    }

    // Right column
    get formattedYearlyPay() {
        return this.formatCurrency(this.jobAppRecord?.data?.fields?.Yearly_Take_home_Pay__c?.value);
    }

    get formattedBiAnnualPay() {
        return this.formatCurrency(this.jobAppRecord?.data?.fields?.Bi_annual_Pay__c?.value);
    }

    get formattedMonthlyPay() {
        return this.formatCurrency(this.jobAppRecord?.data?.fields?.Monthly_Take_home_Pay__c?.value);
    }

    get formattedBiWeeklyPay() {
        return this.formatCurrency(this.jobAppRecord?.data?.fields?.Bi_weekly_Pay__c?.value);
    }

    formatCurrency(value) {
        if (value === undefined || value === null) return '';
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD',
            minimumFractionDigits: 2
        }).format(value);
    }
}
