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

export interface IFileEvent {
  customer?: string;
  date?: string;
  name?: string;
  dataset?: string;
  rows?: string;
  columns?: string;
  bytes?: string;
}

export interface IAnalyticsEvent {
  date?: string;
  time?: string;
  duration?: string;
  files?: string;
  executor?: string;
}

export interface ReduxState {
  token: string;
  analytics: IAnalytics;
  customer: ICustomer;
  customerFile: ICustomerFile;
  fileEvent: IFileEvent;
  analyticsEvent: IAnalyticsEvent;
}

export interface ReduxRoot {
  router: RouterState;
  reducerState: ReduxState;
}