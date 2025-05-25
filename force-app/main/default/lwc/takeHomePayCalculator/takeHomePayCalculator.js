import { LightningElement, api } from 'lwc';

export default class TakeHomePayCalculator extends LightningElement {
    @api recordId;

    renderedCallback() {
        if (this.recordId) {
            console.log('Record ID (rendered):', this.recordId);
        }
    }

}