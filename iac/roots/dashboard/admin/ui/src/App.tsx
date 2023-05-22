// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

import React from 'react';
import {BrowserRouter as Router, Route} from 'react-router-dom';
import HomepageView from "./components/home/home-page";
import LoginView from "./components/home/login";
import AnalyticsTableView from "./components/analytics/analytics-table.index";
import AnalyticsDetailView from "./components/analytics/analytics-detail";
import CustomerTableView from "./components/customers/customer-table.index";
import CustomerDetailView from "./components/customers/customer-detail";
import InputFileTableView from "./components/input-files/input-file-table.index";
import InputFileDetailView from "./components/input-files/input-file-detail";
import OutputFileTableView from "./components/output-files/output-file-table.index";
import OutputFileDetailView from "./components/output-files/output-file-detail";
import FileEventDetailView from "./components/file-events/file-event-detail";
import FileEventTableView from "./components/file-events/file-event-table.index";
import AnalyticsEventTableView from "./components/analytics-events/analytics-event-table.index";
import AnalyticsEventDetailView from "./components/analytics-events/analytics-event-detail";

const App = () => {

  return (
      <div>
        <Router>
          <Route exact path='/' component={HomepageView}/>
          <Route exact path='/Login' component={LoginView}/>
          <Route exact path='/Analytics' component={AnalyticsTableView}/>
          <Route exact path='/AnalyticsDetail' component={AnalyticsDetailView}/>
          <Route exact path='/Customers' component={CustomerTableView}/>
          <Route exact path='/CustomerDetail' component={CustomerDetailView}/>
          <Route exact path='/InputFiles' component={InputFileTableView}/>
          <Route exact path='/InputFile' component={InputFileDetailView}/>
          <Route exact path='/OutputFiles' component={OutputFileTableView}/>
          <Route exact path='/OutputFile' component={OutputFileDetailView}/>
          <Route exact path='/FileEvents' component={FileEventTableView}/>
          <Route exact path='/FileEvent' component={FileEventDetailView}/>
          <Route exact path='/AnalyticsEvents' component={AnalyticsEventTableView}/>
          <Route exact path='/AnalyticsEvent' component={AnalyticsEventDetailView}/>
        </Router>
      </div>
  );
}

export default App;
