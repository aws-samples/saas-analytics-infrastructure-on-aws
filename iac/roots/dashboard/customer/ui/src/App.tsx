// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

import React from 'react';
import {BrowserRouter as Router, Route} from 'react-router-dom';
import HomepageView from "./components/home/home-page";
import LoginView from "./components/home/login";
import InputFileTableView from "./components/input-files/input-file-table.index";
import InputFileDetailView from "./components/input-files/input-file-detail";
import OutputFileTableView from "./components/output-files/output-file-table.index";
import OutputFileDetailView from "./components/output-files/output-file-detail";
import InputFileForm from "./components/input-files/input-file-form";
import SignUpView from "./components/home/signup";
import ConfirmSignUpView from "./components/home/confirm-signup";
import UpdatePasswordView from "./components/home/update-password";

const App = () => {

  return (
      <div>
        <Router>
          <Route exact path='/' component={HomepageView}/>
          <Route exact path='/Login' component={LoginView}/>
          <Route exact path='/SignUp' component={SignUpView}/>
          <Route exact path='/ConfirmSignUp' component={ConfirmSignUpView}/>
          <Route exact path='/UpdatePassword' component={UpdatePasswordView}/>
          <Route exact path='/InputFiles' component={InputFileTableView}/>
          <Route exact path='/InputFile' component={InputFileDetailView}/>
          <Route exact path='/InputFileForm' component={InputFileForm}/>
          <Route exact path='/OutputFiles' component={OutputFileTableView}/>
          <Route exact path='/OutputFile' component={OutputFileDetailView}/>
        </Router>
      </div>
  );
}

export default App;
