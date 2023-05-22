// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

import {IAnalytics, ICustomer, ICustomerFile} from "../../interfaces";

export enum ActionTypes {
    STORE_TOKEN = "STORE_TOKEN",
    STORE_ANALYTICS = "STORE_ANALYTICS",
    STORE_CUSTOMER = "STORE_CUSTOMER",
    STORE_CUSTOMER_FILE = "STORE_CUSTOMER_FILE",
}

export const storeToken = (token:string) => ({
    type: ActionTypes.STORE_TOKEN, token
})

export const storeAnalytics = (analytics:IAnalytics) => ({
    type: ActionTypes.STORE_ANALYTICS, analytics
})

export const storeCustomer = (customer:ICustomer) => ({
    type: ActionTypes.STORE_CUSTOMER, customer
})

export const storeCustomerFile = (customerFile:ICustomerFile) => ({
    type: ActionTypes.STORE_CUSTOMER_FILE, customerFile
})