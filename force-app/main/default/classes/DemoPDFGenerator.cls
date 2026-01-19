public with sharing class DemoPDFGenerator {

    public String brokerName { get; set; }
    public String startDate { get; set; }
    public String endDate { get; set; }
    public Decimal totalPolicyCount { get; set; }
    public Decimal totalPremium { get; set; }
    public Decimal writtenPolicyCount { get; set; }
    public Decimal writtenPremium { get; set; }
    public Decimal hitRate { get; set; }
    public Decimal premiumHitRate { get; set; }
    public Decimal generalLiabilityPremium { get; set; }
    public Decimal professionalLiabilityPremium { get; set; }
    public Decimal inlandMarinePremium { get; set; }
    public Decimal commercialPropertyPremium { get; set; }

    @AuraEnabled
    public static String generatePDF(
        String brokerName,
        String startDate,
        String endDate,
        Decimal totalPolicyCount,
        Decimal totalPremium,
        Decimal writtenPolicyCount,
        Decimal writtenPremium,
        Decimal hitRate,
        Decimal premiumHitRate,
        Decimal generalLiabilityPremium,
        Decimal professionalLiabilityPremium,
        Decimal inlandMarinePremium,
        Decimal commercialPropertyPremium
    ) {
        try {
            PageReference pdfPage = Page.DemoScorecardPDF;

            pdfPage.getParameters().put('brokerName', brokerName != null ? brokerName : '');
            pdfPage.getParameters().put('startDate', startDate != null ? startDate : '');
            pdfPage.getParameters().put('endDate', endDate != null ? endDate : '');
            pdfPage.getParameters().put('totalPolicyCount', String.valueOf(totalPolicyCount != null ? totalPolicyCount : 0));
            pdfPage.getParameters().put('totalPremium', String.valueOf(totalPremium != null ? totalPremium : 0));
            pdfPage.getParameters().put('writtenPolicyCount', String.valueOf(writtenPolicyCount != null ? writtenPolicyCount : 0));
            pdfPage.getParameters().put('writtenPremium', String.valueOf(writtenPremium != null ? writtenPremium : 0));
            pdfPage.getParameters().put('hitRate', String.valueOf(hitRate != null ? hitRate : 0));
            pdfPage.getParameters().put('premiumHitRate', String.valueOf(premiumHitRate != null ? premiumHitRate : 0));
            pdfPage.getParameters().put('generalLiabilityPremium', String.valueOf(generalLiabilityPremium != null ? generalLiabilityPremium : 0));
            pdfPage.getParameters().put('professionalLiabilityPremium', String.valueOf(professionalLiabilityPremium != null ? professionalLiabilityPremium : 0));
            pdfPage.getParameters().put('inlandMarinePremium', String.valueOf(inlandMarinePremium != null ? inlandMarinePremium : 0));
            pdfPage.getParameters().put('commercialPropertyPremium', String.valueOf(commercialPropertyPremium != null ? commercialPropertyPremium : 0));

            System.debug('Page parameters: ' + pdfPage.getParameters());

            Blob pdfBlob;
            if (Test.isRunningTest()) {
                pdfBlob = Blob.valueOf('Test PDF Content');
            } else {
                try {
                    pdfBlob = pdfPage.getContentAsPDF();
                    if (pdfBlob == null) {
                        throw new AuraHandledException('PDF generation failed - blob is null');
                    }
                } catch (Exception e) {
                    System.debug('Error in PDF generation: ' + e.getMessage());
                    System.debug('Error stack trace: ' + e.getStackTraceString());
                    throw new AuraHandledException('PDF Generation Error: ' + e.getMessage());
                }
            }

            return EncodingUtil.base64Encode(pdfBlob);
        } catch(Exception e) {
            System.debug('Error in generatePDF method: ' + e.getMessage());
            System.debug('Error stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException('Error in generatePDF: ' + e.getMessage());
        }
    }
}
