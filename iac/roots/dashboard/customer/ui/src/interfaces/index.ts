// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

import { RouterState } from 'connected-react-router';

export interface IAnalytics {
  name?: string;
  description?: string;
}

export interface ICustomer {
  id?: string;
}

export interface ICustomerFile {
  name?: string;
}

export interface ReduxState {
  token: string;
  analytics: IAnalytics;
  customer: ICustomer;
  customerFile: ICustomerFile;
}

export interface ReduxRoot {
  router: RouterState;
  reducerState: ReduxState;
}