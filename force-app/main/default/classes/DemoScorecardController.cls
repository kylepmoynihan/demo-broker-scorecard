public with sharing class DemoScorecardController {

    public class ScorecardResult {
        @AuraEnabled public String brokerName;
        @AuraEnabled public String startDate;
        @AuraEnabled public String endDate;
        @AuraEnabled public Integer totalPolicyCount;
        @AuraEnabled public Decimal totalPremium;
        @AuraEnabled public Integer writtenPolicyCount;
        @AuraEnabled public Decimal writtenPremium;
        @AuraEnabled public Decimal hitRate;
        @AuraEnabled public Decimal premiumHitRate;
        @AuraEnabled public Decimal generalLiabilityPremium;
        @AuraEnabled public Decimal professionalLiabilityPremium;
        @AuraEnabled public Decimal inlandMarinePremium;
        @AuraEnabled public Decimal commercialPropertyPremium;
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> getBrokers() {
        // Get accounts that are brokers (have policies as broker)
        Set<Id> brokerIds = new Set<Id>();
        for (Policy__c p : [SELECT Broker__c FROM Policy__c WHERE Broker__c != null]) {
            brokerIds.add(p.Broker__c);
        }
        return [SELECT Id, Name FROM Account WHERE Id IN :brokerIds ORDER BY Name];
    }

    @AuraEnabled
    public static ScorecardResult calculateScorecard(Id brokerId, Date startDate, Date endDate) {
        ScorecardResult result = new ScorecardResult();

        // Get broker name
        Account broker = [SELECT Id, Name FROM Account WHERE Id = :brokerId LIMIT 1];
        result.brokerName = broker.Name;
        result.startDate = String.valueOf(startDate);
        result.endDate = String.valueOf(endDate);

        // Query policies for this broker within date range
        List<Policy__c> policies = [
            SELECT Id, Premium__c, Status__c, Coverage_Type__c, Effective_Date__c
            FROM Policy__c
            WHERE Broker__c = :brokerId
            AND Effective_Date__c >= :startDate
            AND Effective_Date__c <= :endDate
        ];

        // Calculate metrics
        Integer totalCount = 0;
        Decimal totalPrem = 0;
        Integer writtenCount = 0;
        Decimal writtenPrem = 0;

        Decimal glPremium = 0;
        Decimal plPremium = 0;
        Decimal imPremium = 0;
        Decimal cpPremium = 0;

        for (Policy__c policy : policies) {
            totalCount++;
            Decimal policyPremium = policy.Premium__c != null ? policy.Premium__c : 0;
            totalPrem += policyPremium;

            if (policy.Status__c == 'Written') {
                writtenCount++;
                writtenPrem += policyPremium;

                String coverageType = policy.Coverage_Type__c;
                if (coverageType == 'General Liability') {
                    glPremium += policyPremium;
                } else if (coverageType == 'Professional Liability') {
                    plPremium += policyPremium;
                } else if (coverageType == 'Inland Marine') {
                    imPremium += policyPremium;
                } else if (coverageType == 'Commercial Property') {
                    cpPremium += policyPremium;
                }
            }
        }

        result.totalPolicyCount = totalCount;
        result.totalPremium = totalPrem;
        result.writtenPolicyCount = writtenCount;
        result.writtenPremium = writtenPrem;

        result.hitRate = totalCount > 0 ? ((Decimal)writtenCount / totalCount * 100).setScale(1) : 0;
        result.premiumHitRate = totalPrem > 0 ? (writtenPrem / totalPrem * 100).setScale(1) : 0;

        result.generalLiabilityPremium = glPremium;
        result.professionalLiabilityPremium = plPremium;
        result.inlandMarinePremium = imPremium;
        result.commercialPropertyPremium = cpPremium;

        return result;
    }
}
