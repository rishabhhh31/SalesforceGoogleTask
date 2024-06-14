import { LightningElement, track, wire } from 'lwc';
import {
    MessageContext,
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE
} from 'lightning/messageService';
import TodosFiltered from '@salesforce/messageChannel/TodosFiltered__c';
import { refreshApex } from "@salesforce/apex";
import getTodoData from '@salesforce/apex/ToDoHandler.getTodoData';

export default class TodoCardList extends LightningElement {
    subscription = null;
    @track filters = {};
    todoRecords = [];
    todoResult;

    @wire(MessageContext)
    messageContext;

    @wire(getTodoData, { filters: '$filters' })
    toDoList(result) {
        this.todoResult = result;
        if (this.todoResult.data) {
            this.todoRecords = this.todoResult.data;
        } else if (this.todoResult.error) {
            console.log(this.todoResult.error);
        }
    }

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                TodosFiltered,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    handleMessage(message) {
        this.filters = message.filters;
    }

    disconnectedCallback() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    get todoRecordsAvailable() {
        return this.todoRecords.length > 0;
    }

    get getTodoCounts() {
        return this.todoRecords.length;
    }

    refreshData() {
        refreshApex(this.todoResult);
    }
}