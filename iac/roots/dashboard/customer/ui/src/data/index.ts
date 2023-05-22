// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

// @ts-ignore
import ApiHandler, { ApiMethod } from '../common/api'

import { ICustomerFile } from '../interfaces'

import { DASHBOARD_ENDPOINTS } from '../config'

export const dashboard_api = new ApiHandler(DASHBOARD_ENDPOINTS.Endpoint, DASHBOARD_ENDPOINTS.ApiKey, DASHBOARD_ENDPOINTS.Resources);

export const getCustomerInputFiles = (token: string, user_params?: any) => dashboard_api.get_authorized_resource<ICustomerFile[]>(
    "get-cust-input-files", token, ApiMethod.GET, null, [])

export const getCustomerOutputFiles = (token: string, user_params?: any) => dashboard_api.get_authorized_resource<ICustomerFile[]>(
    "get-cust-output-files", token, ApiMethod.GET, null, [])

export const getFileContent = (token: string, name: string, user_params?: any) => dashboard_api.get_authorized_resource<ICustomerFile[]>(
    "get-file-content", token, ApiMethod.GET, null, [{ key: "name", value: name }])

export const putFileContent = (token: string, data: any, user_params?: any) => dashboard_api.post_form_data<any>(
    "put-file-content", token, ApiMethod.POST, data, [])

export const updatePassword = (token: string, pool: string, password: string, user_params?: any) => dashboard_api.get_authorized_resource<any>(
    "update-password", token, ApiMethod.POST, { pool: pool, password: password }, [])
