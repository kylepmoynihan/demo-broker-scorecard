public class DemoScorecardMetrics {

    public class PolicyInput {
        @InvocableVariable(required=true)
        public List<Policy__c> policies;
    }

    public class ScorecardOutput {
        @InvocableVariable
        public Integer totalPolicyCount;

        @InvocableVariable
        public Decimal totalPremium;

        @InvocableVariable
        public Integer writtenPolicyCount;

        @InvocableVariable
        public Decimal writtenPremium;

        @InvocableVariable
        public Decimal hitRate;

        @InvocableVariable
        public Decimal premiumHitRate;

        @InvocableVariable
        public Decimal generalLiabilityPremium;

        @InvocableVariable
        public Decimal professionalLiabilityPremium;

        @InvocableVariable
        public Decimal inlandMarinePremium;

        @InvocableVariable
        public Decimal commercialPropertyPremium;
    }

    @InvocableMethod(label='Calculate Demo Scorecard Metrics' description='Calculates metrics for the demo broker scorecard')
    public static List<ScorecardOutput> calculateMetrics(List<PolicyInput> inputs) {
        List<ScorecardOutput> outputs = new List<ScorecardOutput>();

        for (PolicyInput input : inputs) {
            ScorecardOutput output = new ScorecardOutput();

            try {
                Integer totalCount = 0;
                Decimal totalPrem = 0;
                Integer writtenCount = 0;
                Decimal writtenPrem = 0;

                Decimal glPremium = 0;
                Decimal plPremium = 0;
                Decimal imPremium = 0;
                Decimal cpPremium = 0;

                for (Policy__c policy : input.policies) {
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

                output.totalPolicyCount = totalCount;
                output.totalPremium = totalPrem;
                output.writtenPolicyCount = writtenCount;
                output.writtenPremium = writtenPrem;

                output.hitRate = totalCount > 0 ? ((Decimal)writtenCount / totalCount * 100).setScale(1) : 0;
                output.premiumHitRate = totalPrem > 0 ? (writtenPrem / totalPrem * 100).setScale(1) : 0;

                output.generalLiabilityPremium = glPremium;
                output.professionalLiabilityPremium = plPremium;
                output.inlandMarinePremium = imPremium;
                output.commercialPropertyPremium = cpPremium;

            } catch (Exception e) {
                System.debug('Error calculating metrics: ' + e.getMessage());
                output.totalPolicyCount = 0;
                output.totalPremium = 0;
                output.writtenPolicyCount = 0;
                output.writtenPremium = 0;
                output.hitRate = 0;
                output.premiumHitRate = 0;
                output.generalLiabilityPremium = 0;
                output.professionalLiabilityPremium = 0;
                output.inlandMarinePremium = 0;
                output.commercialPropertyPremium = 0;
            }

            outputs.add(output);
        }

        return outputs;
    }
}
