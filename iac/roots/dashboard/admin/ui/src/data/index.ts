// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

// @ts-ignore
import ApiHandler, {ApiMethod} from '../common/api'

import {
  IAnalytics, IAnalyticsEvent, ICustomer, ICustomerFile, IFileEvent
} from '../interfaces'

import {
  ANALYTICS1_ENDPOINTS, DASHBOARD_ENDPOINTS
} from '../config'

export const analytics1_api = new ApiHandler(
    ANALYTICS1_ENDPOINTS.Endpoint, ANALYTICS1_ENDPOINTS.ApiKey, ANALYTICS1_ENDPOINTS.Resources
);

export const dashboard_api = new ApiHandler(
    DASHBOARD_ENDPOINTS.Endpoint, DASHBOARD_ENDPOINTS.ApiKey, DASHBOARD_ENDPOINTS.Resources
);

export const executeAnalytics1 = (token: string, user_params?:any) => analytics1_api.get_authorized_resource<any>(
    "execute", token, ApiMethod.POST, null, [])

export const getAnalytics = (token: string, user_params?:any) => dashboard_api.get_authorized_resource<IAnalytics[]>(
    "get-analytics", token, ApiMethod.GET, null, [])

export const getCustomers = (token: string, user_params?:any) => dashboard_api.get_authorized_resource<ICustomer[]>(
    "get-customers", token, ApiMethod.GET, null, [])

export const getInputFiles = (token: string, user_params?:any) => dashboard_api.get_authorized_resource<ICustomerFile[]>(
    "get-input-files", token, ApiMethod.GET, null, [])

export const getOutputFiles = (token: string, user_params?:any) => dashboard_api.get_authorized_resource<ICustomerFile[]>(
    "get-output-files", token, ApiMethod.GET, null, [])

export const getFileEvents = (token: string, user_params?:any) => dashboard_api.get_authorized_resource<IFileEvent[]>(
    "get-file-events", token, ApiMethod.GET, null, [])

export const getAnalyticsEvents = (token: string, date: string, user_params?:any) => dashboard_api.get_authorized_resource<IAnalyticsEvent[]>(
    "get-analytics-events", token, ApiMethod.GET, null, [{key:"date", value:date}])

