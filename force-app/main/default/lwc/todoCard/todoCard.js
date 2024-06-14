import { LightningElement, api } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TodoCard extends LightningElement {
    taskRecord;
    taskId;
    cardTitle;
    dueDate;
    description;
    typeBadgeLabel;
    priorityBadgeLabel;
    priorityBadgeColor;
    priority;
    iconName;
    completedState;

    @api
    get todo() {
        return this.taskRecord;
    }
    set todo(value) {
        this.taskRecord = value;
        this.taskId = value.Id;
        this.cardTitle = value.Name;
        this.dueDate = this.formatDueDate(value.Due_Date__c);
        this.description = value.Notes__c;
        this.priority = value.Priority__c;
        this.completedState = value.Is_Completed__c;
        this.priorityBadgeLabel = value.Priority__c;
        this.priorityBadgeColor = this.getPriorityBadgeColor(value.Priority__c);
        this.typeBadgeLabel = value.Type__c;
        this.iconName = this.getIconName(value.Type__c);
    }

    async handleCompletion(event) {
        try {
            const fields = {};
            fields.Id = this.taskId;
            fields.Is_Completed__c = !this.completedState;
            const recordInput = { fields };
            await updateRecord(recordInput)
            this.completedState = !this.completedState;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: `To-Do ${this.completedState ? 'unmarked' : 'marked'} as completed.`,
                    variant: 'success',
                })
            );
        } catch (error) {
            console.error(error.body.message);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'An error occurred while updating the record.',
                    variant: 'error',
                })
            );
        }
    }

    formatDueDate(dueDate) {
        const options = { day: 'numeric', month: 'short', hour: 'numeric', minute: 'numeric', hour12: true };
        return new Intl.DateTimeFormat('en-US', options).format(new Date(dueDate));
    }

    getPriorityBadgeColor(priorityType) {
        let backgroundColor = '';
        let color = '';
        if (priorityType == 'High') {
            color = '#ff2e2e';
            backgroundColor = '#ffc8c8';
        } else if (priorityType == 'Medium') {
            color = '#a6a62a';
            backgroundColor = '#ffffb5';
        } else {
            color = '#0b880b';
            backgroundColor = '#b5ffb5';
        }
        return `--slds-c-badge-color-background: ${backgroundColor}; --slds-c-badge-text-color: ${color}`;
    }

    getIconName(taskType) {
        switch (taskType) {
            case "Personal":
                return 'utility:socialshare';
            case 'Work':
                return "utility:company";
            case 'Household':
                return "utility:home";
            case 'Office':
                return "utility:sender_email";
            case 'Academic':
                return "utility:knowledge_base";
            default:
                console.warn('Unexpected or undefined todo type:', type);
                return "utility:task";
        }
    }
}