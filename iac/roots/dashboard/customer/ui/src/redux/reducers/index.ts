// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

import {combineReducers, Reducer} from 'redux';
import {History} from 'history';
import {connectRouter} from 'connected-react-router';
import {ReduxState} from '../../interfaces';
import {ActionTypes} from "../actions";

let initialState: ReduxState = {
  token: "",
  analytics: {},
  customer: {},
  customerFile: {}
};

export const AppReducer: Reducer<ReduxState> = (state = initialState, action) => {

  switch(action.type) {
    case ActionTypes.STORE_TOKEN: {
      return {
        ...state,
        token: action.token
      };
    }
    case ActionTypes.STORE_ANALYTICS: {
      return {
        ...state,
        analytics: action.analytics
      };
    }
    case ActionTypes.STORE_CUSTOMER: {
      return {
        ...state,
        customer: action.customer
      };
    }
    case ActionTypes.STORE_CUSTOMER_FILE: {
      return {
        ...state,
        customerFile: action.customerFile
      };
    }
  }
  return state;
};

const createRootReducer = (history: History) => combineReducers({
  router: connectRouter(history),
  reducerState: AppReducer
});

export default createRootReducer;
export type RootState = ReturnType<typeof createRootReducer>;