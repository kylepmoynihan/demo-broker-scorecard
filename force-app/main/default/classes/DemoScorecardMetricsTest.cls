@isTest
public class DemoScorecardMetricsTest {

    @TestSetup
    static void setupTestData() {
        Account broker = new Account(Name = 'Test Brokerage');
        insert broker;

        Account insuredAccount = new Account(Name = 'Test Insured');
        insert insuredAccount;

        List<Policy__c> policies = new List<Policy__c>();

        policies.add(new Policy__c(
            Broker__c = broker.Id,
            Account__c = insuredAccount.Id,
            Effective_Date__c = Date.newInstance(2025, 1, 15),
            Expiration_Date__c = Date.newInstance(2026, 1, 15),
            Premium__c = 10000,
            Status__c = 'Written',
            Coverage_Type__c = 'General Liability'
        ));

        policies.add(new Policy__c(
            Broker__c = broker.Id,
            Account__c = insuredAccount.Id,
            Effective_Date__c = Date.newInstance(2025, 2, 1),
            Expiration_Date__c = Date.newInstance(2026, 2, 1),
            Premium__c = 15000,
            Status__c = 'Written',
            Coverage_Type__c = 'Professional Liability'
        ));

        policies.add(new Policy__c(
            Broker__c = broker.Id,
            Account__c = insuredAccount.Id,
            Effective_Date__c = Date.newInstance(2025, 3, 10),
            Expiration_Date__c = Date.newInstance(2026, 3, 10),
            Premium__c = 8000,
            Status__c = 'Written',
            Coverage_Type__c = 'Inland Marine'
        ));

        policies.add(new Policy__c(
            Broker__c = broker.Id,
            Account__c = insuredAccount.Id,
            Effective_Date__c = Date.newInstance(2025, 4, 20),
            Expiration_Date__c = Date.newInstance(2026, 4, 20),
            Premium__c = 12000,
            Status__c = 'Written',
            Coverage_Type__c = 'Commercial Property'
        ));

        policies.add(new Policy__c(
            Broker__c = broker.Id,
            Account__c = insuredAccount.Id,
            Effective_Date__c = Date.newInstance(2025, 5, 5),
            Expiration_Date__c = Date.newInstance(2026, 5, 5),
            Premium__c = 20000,
            Status__c = 'Quoted',
            Coverage_Type__c = 'General Liability'
        ));

        insert policies;
    }

    @isTest
    static void testCalculateMetrics() {
        List<Policy__c> policies = [
            SELECT Id, Broker__c, Account__c, Effective_Date__c, Expiration_Date__c,
                   Premium__c, Status__c, Coverage_Type__c
            FROM Policy__c
        ];

        DemoScorecardMetrics.PolicyInput input = new DemoScorecardMetrics.PolicyInput();
        input.policies = policies;

        Test.startTest();
        List<DemoScorecardMetrics.ScorecardOutput> outputs = DemoScorecardMetrics.calculateMetrics(
            new List<DemoScorecardMetrics.PolicyInput>{ input }
        );
        Test.stopTest();

        System.assertEquals(1, outputs.size(), 'Should return one output');

        DemoScorecardMetrics.ScorecardOutput output = outputs[0];

        System.assertEquals(5, output.totalPolicyCount, 'Should have 5 total policies');
        System.assertEquals(65000, output.totalPremium, 'Total premium should be 65000');
        System.assertEquals(4, output.writtenPolicyCount, 'Should have 4 written policies');
        System.assertEquals(45000, output.writtenPremium, 'Written premium should be 45000');
        System.assertEquals(80.0, output.hitRate, 'Hit rate should be 80%');
        System.assertEquals(69.2, output.premiumHitRate, 'Premium hit rate should be ~69.2%');
        System.assertEquals(10000, output.generalLiabilityPremium, 'GL premium should be 10000');
        System.assertEquals(15000, output.professionalLiabilityPremium, 'PL premium should be 15000');
        System.assertEquals(8000, output.inlandMarinePremium, 'IM premium should be 8000');
        System.assertEquals(12000, output.commercialPropertyPremium, 'CP premium should be 12000');
    }

    @isTest
    static void testCalculateMetricsWithEmptyList() {
        DemoScorecardMetrics.PolicyInput input = new DemoScorecardMetrics.PolicyInput();
        input.policies = new List<Policy__c>();

        Test.startTest();
        List<DemoScorecardMetrics.ScorecardOutput> outputs = DemoScorecardMetrics.calculateMetrics(
            new List<DemoScorecardMetrics.PolicyInput>{ input }
        );
        Test.stopTest();

        System.assertEquals(1, outputs.size(), 'Should return one output');

        DemoScorecardMetrics.ScorecardOutput output = outputs[0];

        System.assertEquals(0, output.totalPolicyCount, 'Should have 0 total policies');
        System.assertEquals(0, output.totalPremium, 'Total premium should be 0');
        System.assertEquals(0, output.writtenPolicyCount, 'Should have 0 written policies');
        System.assertEquals(0, output.writtenPremium, 'Written premium should be 0');
        System.assertEquals(0, output.hitRate, 'Hit rate should be 0');
        System.assertEquals(0, output.premiumHitRate, 'Premium hit rate should be 0');
    }

    @isTest
    static void testCalculateMetricsWithNullPremium() {
        Account broker = [SELECT Id FROM Account WHERE Name = 'Test Brokerage' LIMIT 1];
        Account insured = [SELECT Id FROM Account WHERE Name = 'Test Insured' LIMIT 1];

        Policy__c policyWithNullPremium = new Policy__c(
            Broker__c = broker.Id,
            Account__c = insured.Id,
            Effective_Date__c = Date.newInstance(2025, 6, 1),
            Expiration_Date__c = Date.newInstance(2026, 6, 1),
            Premium__c = null,
            Status__c = 'Written',
            Coverage_Type__c = 'General Liability'
        );
        insert policyWithNullPremium;

        List<Policy__c> policies = new List<Policy__c>{ policyWithNullPremium };

        DemoScorecardMetrics.PolicyInput input = new DemoScorecardMetrics.PolicyInput();
        input.policies = policies;

        Test.startTest();
        List<DemoScorecardMetrics.ScorecardOutput> outputs = DemoScorecardMetrics.calculateMetrics(
            new List<DemoScorecardMetrics.PolicyInput>{ input }
        );
        Test.stopTest();

        System.assertEquals(1, outputs.size(), 'Should return one output');
        System.assertEquals(1, outputs[0].totalPolicyCount, 'Should have 1 policy');
        System.assertEquals(0, outputs[0].totalPremium, 'Total premium should be 0 for null premium');
    }
}
