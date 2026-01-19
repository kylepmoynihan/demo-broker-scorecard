@isTest
public class DemoPDFGeneratorTest {

    @isTest
    static void testGeneratePDF() {
        Test.startTest();
        String result = DemoPDFGenerator.generatePDF(
            'Test Brokerage',
            '2025-01-01',
            '2025-12-31',
            13,
            250000,
            10,
            200000,
            76.9,
            80.0,
            75000,
            50000,
            35000,
            40000
        );
        Test.stopTest();

        System.assertNotEquals(null, result, 'PDF should be generated');
        System.assert(result.length() > 0, 'PDF content should not be empty');
    }

    @isTest
    static void testGeneratePDFWithNullValues() {
        Test.startTest();
        String result = DemoPDFGenerator.generatePDF(
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null
        );
        Test.stopTest();

        System.assertNotEquals(null, result, 'PDF should be generated even with null values');
    }

    @isTest
    static void testGeneratePDFWithZeroValues() {
        Test.startTest();
        String result = DemoPDFGenerator.generatePDF(
            'Empty Brokerage',
            '2025-01-01',
            '2025-12-31',
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0
        );
        Test.stopTest();

        System.assertNotEquals(null, result, 'PDF should be generated with zero values');
    }

    @isTest
    static void testPropertyGettersAndSetters() {
        DemoPDFGenerator generator = new DemoPDFGenerator();

        generator.brokerName = 'Test Broker';
        generator.startDate = '2025-01-01';
        generator.endDate = '2025-12-31';
        generator.totalPolicyCount = 10;
        generator.totalPremium = 100000;
        generator.writtenPolicyCount = 8;
        generator.writtenPremium = 80000;
        generator.hitRate = 80.0;
        generator.premiumHitRate = 80.0;
        generator.generalLiabilityPremium = 20000;
        generator.professionalLiabilityPremium = 20000;
        generator.inlandMarinePremium = 20000;
        generator.commercialPropertyPremium = 20000;

        System.assertEquals('Test Broker', generator.brokerName);
        System.assertEquals('2025-01-01', generator.startDate);
        System.assertEquals('2025-12-31', generator.endDate);
        System.assertEquals(10, generator.totalPolicyCount);
        System.assertEquals(100000, generator.totalPremium);
        System.assertEquals(8, generator.writtenPolicyCount);
        System.assertEquals(80000, generator.writtenPremium);
        System.assertEquals(80.0, generator.hitRate);
        System.assertEquals(80.0, generator.premiumHitRate);
        System.assertEquals(20000, generator.generalLiabilityPremium);
        System.assertEquals(20000, generator.professionalLiabilityPremium);
        System.assertEquals(20000, generator.inlandMarinePremium);
        System.assertEquals(20000, generator.commercialPropertyPremium);
    }
}
