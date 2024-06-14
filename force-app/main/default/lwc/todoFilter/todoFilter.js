import { LightningElement, wire } from 'lwc';
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import PRIORITY_FIELD from "@salesforce/schema/To_Do__c.Priority__c";
import TYPE_FIELD from "@salesforce/schema/To_Do__c.Type__c";
import TO_DO_OBJECT from "@salesforce/schema/To_Do__c";
import { publish, MessageContext } from 'lightning/messageService';
import TodosFiltered from '@salesforce/messageChannel/TodosFiltered__c';
const DELAY = 500;
export default class TodoFilter extends LightningElement {
    subscription = null;
    timeout;
    sortByValue = 'Due_Date__c ASC';

    priorityOptions = [];
    selectedPriority = [];

    typeOptions = [];
    selectedType = [];

    filters = {
        searchKey: '',
        sortBy: 'Due_Date__c ASC',
        types: this.selectedType,
        priorities: this.selectedPriority,
    };

    @wire(MessageContext)
    messageContext;

    @wire(getObjectInfo, { objectApiName: TO_DO_OBJECT })
    toDoObjectProperty;

    @wire(getPicklistValues, { recordTypeId: '$toDoObjectProperty.data.defaultRecordTypeId', fieldApiName: PRIORITY_FIELD })
    priorityPicklist({ data, error }) {
        if (data) {
            let { values } = data;
            this.priorityOptions = values.map(v => {
                this.selectedPriority.push(v.value);
                return { label: v.label, value: v.value };
            })
        } else {
            console.log(error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$toDoObjectProperty.data.defaultRecordTypeId', fieldApiName: TYPE_FIELD })
    typePicklist({ data, error }) {
        if (data) {
            let { values } = data;
            this.typeOptions = values.map(v => {
                this.selectedType.push(v.value);
                return { label: v.label, value: v.value };
            })
        } else {
            console.log(error);
        }
    }

    get sortByOptions() {
        return [
            { label: 'Due Date (Early First)', value: 'Due_Date__c ASC' },
            { label: 'Due Date (Later First)', value: 'Due_Date__c DESC' },
            { label: 'To-Do Title (A to Z)', value: 'Name ASC' },
            { label: 'To-Do Title (Z to A)', value: 'Name DESC' }
        ]
    }

    handleSearchKeyChange(event) {
        this.filters.searchKey = event.target.value;
        this.delayedFireFilterChangeEvent();
    }

    handleSortByChange(event) {
        this.filters.sortBy = event.detail.value;
        this.publishEvent()
    }

    handlePriorityChange(event) {
        this.filters.priorities = event.detail.value;
        this.publishEvent();
    }

    handleTypeChange(event) {
        this.filters.types = event.detail.value;
        this.publishEvent();
    }
    get priorityOptionShow() {
        return this.priorityOptions.length > 0;
    }

    get typeOptionShow() {
        return this.typeOptions.length > 0;
    }

    publishEvent() {
        publish(this.messageContext, TodosFiltered, {
            filters: this.filters
        });
    }
    delayedFireFilterChangeEvent() {
        clearTimeout(this.timeout);
        this.timeout = setTimeout(() => {
            this.publishEvent();
        }, DELAY)
    }
}