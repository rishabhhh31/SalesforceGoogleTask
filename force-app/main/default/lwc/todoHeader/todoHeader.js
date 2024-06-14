import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getQuote from '@salesforce/apex/GetRandomQuote.getQuote';
import TO_DO_OBJECT from '@salesforce/schema/To_Do__c';
import NAME from "@salesforce/schema/To_Do__c.Name";
import PRIORITY from "@salesforce/schema/To_Do__c.Priority__c";
import NOTES from "@salesforce/schema/To_Do__c.Notes__c";
import DUE_DATE from "@salesforce/schema/To_Do__c.Due_Date__c";
import TYPE from "@salesforce/schema/To_Do__c.Type__c";

const fields = [NAME, PRIORITY, NOTES, DUE_DATE, TYPE];
const fieldApiNames = fields.map(f => f.fieldApiName);
export default class TodoHeader extends LightningElement {
    Name;
    Priority;
    Notes;
    Due_Date;
    Type;
    time;
    greeting;
    quote;
    loading = true;
    objectApiName = TO_DO_OBJECT;
    @api flexipageRegionWidth;

    connectedCallback() {
        this.getRandomQuote();
        this.setTime();
        [this.Name, this.Priority, this.Notes, this.Due_Date, this.Type] = fieldApiNames;
    }

    async getRandomQuote() {
        let response = await getQuote();
        if (response != null) {
            let data = JSON.parse(response);
            this.quote = data[0].content;
        }
        this.loading = false;
    }

    setTime() {
        let today = new Date();
        let hours = today.getHours();
        let minutes = today.getMinutes().toString().padStart(2, '0');
        let period = hours >= 12 ? 'PM' : 'AM';
        hours = hours % 12 || 12;
        this.time = `${hours} : ${minutes} ${period}`;
        this.setGreeting(today.getHours());
    }

    setGreeting(hours) {
        if (hours < 12) {
            this.greeting = 'Good Morning 🌄';
        }
        else if (hours >= 12 && hours <= 17) {
            this.greeting = 'Good Afternoon ☀️';
        } else {
            this.greeting = 'Good evening';
        }
    }

    get largePageSize() {
        return this.flexipageRegionWidth === "SMALL"
            ? "12"
            : this.flexipageRegionWidth === "MEDIUM"
                ? "8"
                : "12";
    }

    handleSuccess(event) {
        if (event.detail.id) {
            let taskName = event.detail.fields.Name.value;
            const evt = new ShowToastEvent({
                title: 'Success',
                message: 'Record {0} created!',
                messageData: [
                    {
                        url: `/${event.detail.id}`,
                        label: taskName,
                    },
                ],
                variant: 'success'
            });
            this.dispatchEvent(evt);
            let inputFields = this.template.querySelectorAll('lightning-input-field');
            inputFields.forEach(input => input.reset());
        }
    }

    errorHandler(event) {
        console.log('error', event);
    }
}