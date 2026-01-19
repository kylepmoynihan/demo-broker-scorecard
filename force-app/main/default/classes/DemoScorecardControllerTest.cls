@isTest
private class DemoScorecardControllerTest {

    @TestSetup
    static void setupTestData() {
        // Create broker account
        Account broker = new Account(Name = 'Test Broker');
        insert broker;

        // Create insured account
        Account insured = new Account(Name = 'Test Insured');
        insert insured;

        // Create policies
        List<Policy__c> policies = new List<Policy__c>();

        // Written policies
        policies.add(new Policy__c(
            Broker__c = broker.Id,
            Account__c = insured.Id,
            Effective_Date__c = Date.newInstance(2025, 3, 1),
            Expiration_Date__c = Date.newInstance(2026, 3, 1),
            Premium__c = 10000,
            Status__c = 'Written',
            Coverage_Type__c = 'General Liability'
        ));

        policies.add(new Policy__c(
            Broker__c = broker.Id,
            Account__c = insured.Id,
            Effective_Date__c = Date.newInstance(2025, 4, 1),
            Expiration_Date__c = Date.newInstance(2026, 4, 1),
            Premium__c = 20000,
            Status__c = 'Written',
            Coverage_Type__c = 'Professional Liability'
        ));

        policies.add(new Policy__c(
            Broker__c = broker.Id,
            Account__c = insured.Id,
            Effective_Date__c = Date.newInstance(2025, 5, 1),
            Expiration_Date__c = Date.newInstance(2026, 5, 1),
            Premium__c = 15000,
            Status__c = 'Written',
            Coverage_Type__c = 'Inland Marine'
        ));

        policies.add(new Policy__c(
            Broker__c = broker.Id,
            Account__c = insured.Id,
            Effective_Date__c = Date.newInstance(2025, 6, 1),
            Expiration_Date__c = Date.newInstance(2026, 6, 1),
            Premium__c = 25000,
            Status__c = 'Written',
            Coverage_Type__c = 'Commercial Property'
        ));

        // Quoted policy
        policies.add(new Policy__c(
            Broker__c = broker.Id,
            Account__c = insured.Id,
            Effective_Date__c = Date.newInstance(2025, 7, 1),
            Expiration_Date__c = Date.newInstance(2026, 7, 1),
            Premium__c = 5000,
            Status__c = 'Quoted',
            Coverage_Type__c = 'General Liability'
        ));

        insert policies;
    }

    @isTest
    static void testGetBrokers() {
        Test.startTest();
        List<Account> brokers = DemoScorecardController.getBrokers();
        Test.stopTest();

        System.assertEquals(1, brokers.size(), 'Should return one broker');
        System.assertEquals('Test Broker', brokers[0].Name, 'Broker name should match');
    }

    @isTest
    static void testCalculateScorecard() {
        Account broker = [SELECT Id FROM Account WHERE Name = 'Test Broker' LIMIT 1];

        Test.startTest();
        DemoScorecardController.ScorecardResult result = DemoScorecardController.calculateScorecard(
            broker.Id,
            Date.newInstance(2025, 1, 1),
            Date.newInstance(2025, 12, 31)
        );
        Test.stopTest();

        System.assertEquals('Test Broker', result.brokerName, 'Broker name should match');
        System.assertEquals(5, result.totalPolicyCount, 'Should have 5 total policies');
        System.assertEquals(75000, result.totalPremium, 'Total premium should be 75000');
        System.assertEquals(4, result.writtenPolicyCount, 'Should have 4 written policies');
        System.assertEquals(70000, result.writtenPremium, 'Written premium should be 70000');
        System.assertEquals(80.0, result.hitRate, 'Hit rate should be 80%');
        System.assertEquals(10000, result.generalLiabilityPremium, 'GL premium should be 10000');
        System.assertEquals(20000, result.professionalLiabilityPremium, 'PL premium should be 20000');
        System.assertEquals(15000, result.inlandMarinePremium, 'IM premium should be 15000');
        System.assertEquals(25000, result.commercialPropertyPremium, 'CP premium should be 25000');
    }

    @isTest
    static void testCalculateScorecardWithDateFilter() {
        Account broker = [SELECT Id FROM Account WHERE Name = 'Test Broker' LIMIT 1];

        Test.startTest();
        // Filter to only include first 2 policies (March and April)
        DemoScorecardController.ScorecardResult result = DemoScorecardController.calculateScorecard(
            broker.Id,
            Date.newInstance(2025, 3, 1),
            Date.newInstance(2025, 4, 30)
        );
        Test.stopTest();

        System.assertEquals(2, result.totalPolicyCount, 'Should have 2 policies in date range');
        System.assertEquals(30000, result.totalPremium, 'Total premium should be 30000');
    }

    @isTest
    static void testCalculateScorecardNoResults() {
        Account broker = [SELECT Id FROM Account WHERE Name = 'Test Broker' LIMIT 1];

        Test.startTest();
        // Date range with no policies
        DemoScorecardController.ScorecardResult result = DemoScorecardController.calculateScorecard(
            broker.Id,
            Date.newInstance(2024, 1, 1),
            Date.newInstance(2024, 12, 31)
        );
        Test.stopTest();

        System.assertEquals(0, result.totalPolicyCount, 'Should have 0 policies');
        System.assertEquals(0, result.hitRate, 'Hit rate should be 0');
    }
}
