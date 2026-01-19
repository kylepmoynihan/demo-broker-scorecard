import { LightningElement, track, wire } from 'lwc';
import getBrokers from '@salesforce/apex/DemoScorecardController.getBrokers';
import calculateScorecard from '@salesforce/apex/DemoScorecardController.calculateScorecard';
import generatePDF from '@salesforce/apex/DemoPDFGenerator.generatePDF';

export default class DemoScorecardDisplay extends LightningElement {
    @track brokerOptions = [];
    @track selectedBrokerId = '';
    @track inputStartDate = '';
    @track inputEndDate = '';
    @track scorecardData = {};
    @track showResults = false;
    @track isLoading = false;
    @track errorMessage = '';

    @wire(getBrokers)
    wiredBrokers({ error, data }) {
        if (data) {
            this.brokerOptions = data.map(broker => ({
                label: broker.Name,
                value: broker.Id
            }));
            this.errorMessage = '';
        } else if (error) {
            this.errorMessage = 'Error loading brokers: ' + (error.body?.message || error.message);
            this.brokerOptions = [];
        }
    }

    get isGenerateDisabled() {
        return !this.selectedBrokerId || !this.inputStartDate || !this.inputEndDate || this.isLoading;
    }

    get formattedTotalPremium() {
        return this.formatCurrency(this.scorecardData.totalPremium);
    }

    get formattedWrittenPremium() {
        return this.formatCurrency(this.scorecardData.writtenPremium);
    }

    get formattedGLPremium() {
        return this.formatCurrency(this.scorecardData.generalLiabilityPremium);
    }

    get formattedPLPremium() {
        return this.formatCurrency(this.scorecardData.professionalLiabilityPremium);
    }

    get formattedIMPremium() {
        return this.formatCurrency(this.scorecardData.inlandMarinePremium);
    }

    get formattedCPPremium() {
        return this.formatCurrency(this.scorecardData.commercialPropertyPremium);
    }

    formatCurrency(value) {
        if (value === null || value === undefined) return '$0.00';
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD'
        }).format(value);
    }

    handleBrokerChange(event) {
        this.selectedBrokerId = event.detail.value;
    }

    handleStartDateChange(event) {
        this.inputStartDate = event.detail.value;
    }

    handleEndDateChange(event) {
        this.inputEndDate = event.detail.value;
    }

    handleGenerateScorecard() {
        this.isLoading = true;
        this.errorMessage = '';

        calculateScorecard({
            brokerId: this.selectedBrokerId,
            startDate: this.inputStartDate,
            endDate: this.inputEndDate
        })
            .then(result => {
                this.scorecardData = result;
                this.showResults = true;
                this.isLoading = false;
            })
            .catch(error => {
                this.errorMessage = 'Error calculating scorecard: ' + (error.body?.message || error.message);
                this.isLoading = false;
            });
    }

    handleBack() {
        this.showResults = false;
        this.scorecardData = {};
    }

    handleGeneratePDF() {
        this.isLoading = true;

        generatePDF({
            brokerName: this.scorecardData.brokerName,
            startDate: this.scorecardData.startDate,
            endDate: this.scorecardData.endDate,
            totalPolicyCount: this.scorecardData.totalPolicyCount,
            totalPremium: this.scorecardData.totalPremium,
            writtenPolicyCount: this.scorecardData.writtenPolicyCount,
            writtenPremium: this.scorecardData.writtenPremium,
            hitRate: this.scorecardData.hitRate,
            premiumHitRate: this.scorecardData.premiumHitRate,
            generalLiabilityPremium: this.scorecardData.generalLiabilityPremium,
            professionalLiabilityPremium: this.scorecardData.professionalLiabilityPremium,
            inlandMarinePremium: this.scorecardData.inlandMarinePremium,
            commercialPropertyPremium: this.scorecardData.commercialPropertyPremium
        })
            .then(result => {
                this.downloadPDF(result);
                this.isLoading = false;
            })
            .catch(error => {
                this.errorMessage = 'Error generating PDF: ' + (error.body?.message || error.message);
                this.isLoading = false;
            });
    }

    downloadPDF(base64Data) {
        try {
            const byteCharacters = atob(base64Data);
            const byteNumbers = new Array(byteCharacters.length);
            for (let i = 0; i < byteCharacters.length; i++) {
                byteNumbers[i] = byteCharacters.charCodeAt(i);
            }
            const byteArray = new Uint8Array(byteNumbers);
            const blob = new Blob([byteArray], { type: 'application/pdf' });

            const fileName = `Broker_Scorecard_${this.scorecardData.brokerName || 'Report'}_${new Date().toISOString().split('T')[0]}.pdf`;

            const link = document.createElement('a');
            link.href = URL.createObjectURL(blob);
            link.download = fileName;
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            URL.revokeObjectURL(link.href);
        } catch (error) {
            this.errorMessage = 'Error downloading PDF: ' + error.message;
        }
    }
}
