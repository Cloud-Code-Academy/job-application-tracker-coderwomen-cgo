public with sharing class TakehomePayEstimatorHandler {
    public static void calcTakehomePay(List<Job_Application__c> jobApplications,Map<Id, Job_Application__c> oldMap) {
        //Salary
        //Standard Deduction
        //Taxable income
        //Tax Rate
        List<Job_Application__c>appsWithSalary = new List<Job_Application__c>();
        for (Job_Application__c ja : jobApplications) {
            //check is old value and new value id the same
            if(ja.Salary__c != null && (oldMap == null || !oldMap.containsKey(ja.Id) || ja.Salary__c != oldMap.get(ja.Id).Salary__c)){
               
                appsWithSalary.add(ja);
            }
        }
        if (appsWithSalary.isEmpty()) {
           return; 
        }

        

        Standard_Deduction__mdt sd = Standard_Deduction__mdt.getInstance('Default');
        Decimal sdDeduction = sd.Default__c;

        Social_Security_Settings__mdt ss = Social_Security_Settings__mdt.getInstance('Default');
        Decimal ssRate = ss.Rate__c;
        Decimal ssWageBase = ss.Wage_Base__c;

        Medicare_Settings__mdt ms = Medicare_Settings__mdt.getInstance('Default');
        Decimal msRate = ms.Rate__c;

        List<Tax_Bracket__mdt> br = [SELECT Lower_Threshold__c,Upper_Threshold__c,Rate__c,	Filing_Status__c FROM Tax_Bracket__mdt where Filing_Status__c = 'Single' ORDER BY Lower_Threshold__c];

        for (Job_Application__c jApp : appsWithSalary) {
           Decimal taxableIncome = jApp.Salary__c - sdDeduction;
           if (taxableIncome < 0) {
              taxableIncome = 0;
           }
               Decimal fed  = 0;
           
             for (Tax_Bracket__mdt tb : br) {
                Decimal low = TB.Lower_Threshold__c;
                Decimal high = tb.Upper_Threshold__c != null ? tb.Upper_Threshold__c : taxableIncome;
                if (taxableIncome > low) {
                    Decimal taxcut = Math.min(taxableIncome,high) - low;
                    fed += taxcut * tb.Rate__c;
                }
                if (taxableIncome <= high) {
                    break;
                }
             }
             fed = fed.setScale(2);
              
              Decimal ssTaxable  = Math.min(jApp.Salary__c, ssWageBase);
              Decimal ssTax = (ssTaxable * ssRate).setScale(2);
              Decimal mc   = (jApp.Salary__c * msRate).setScale(2);
              Decimal annualTakehome = (jApp.Salary__c - (fed + ssTax + mc)).setScale(2);
              Decimal biAnnualTakehome = (annualTakehome / 2).setScale(2);
              Decimal monthlyTakehome = (annualTakehome / 12).setScale(2);
              Decimal biWeeklyPay = (annualTakehome / 26).setScale(2);

            
           jApp.Federal_Income_Tax__c = fed;
           jApp.Medicare_Withholding__c = mc;
           jApp.Social_Security__c = ssTax;
           jApp.Yearly_Take_home_Pay__c = annualTakehome;
           jApp.Monthly_Take_home_Pay__c = monthlyTakehome;
           jApp.Bi_annual_Pay__c = biAnnualTakehome;
           jApp.Bi_weekly_Pay__c = biWeeklyPay;
           
        }

    }

    // Private static Decimal calculateFederalIncomeTax(Decimal taxableIncome){

    // }
}