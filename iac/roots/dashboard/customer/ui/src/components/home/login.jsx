import React, { useState } from 'react';

import '../common/styles.css';
import '../../styles/base.scss';
import {
  Box,
  Button,
  Flashbar,
  Grid,
  HelpPanel,
  SpaceBetween
} from "@cloudscape-design/components";
import { Navigation } from "../common/navigation";
import { CustomAppLayout } from "../common/app-layout";
import Input from "@cloudscape-design/components/input";
import { storeToken } from "../../redux/actions";

import { Auth } from "aws-amplify";
import { useHistory } from "react-router-dom";
import { useDispatch } from "react-redux";
import { v4 as uuid4 } from "uuid";
import jwt_decode from 'jwt-decode'

export default class LoginView extends React.Component {
  render() {
    return (
      <CustomAppLayout
        navigation={<Navigation activeHref="/" />}
        navigationOpen={false}
        content={<LoginContent />}
        contentType="default"
        tools={<ToolsContent />}
        toolsHide={false}
      // labels={appLayoutNavigationLabels}
      />
    );
  }
}

export const ToolsContent = () => (
  <HelpPanel
    header={<h2>###APP_TITLE###</h2>}
    footer={
      <>
      </>
    }
  >
    <p>
      This solution demonstrates ###APP_TITLE###.
    </p>
  </HelpPanel>
);

// The content in the main content area of the App layout
export function LoginContent() {

  const history = useHistory();
  const dispatch = useDispatch();

  const [user, setUser] = React.useState("");
  const [password, setPassword] = React.useState("");
  const [notifications, setNotifications] = useState([]);

  const addNotification = (message: string) => {
    const list = []
    for (let notification of notifications) {
      list.push(notification)
    }
    list.push({
      type: 'error',
      content: message,
      statusIconAriaLabel: 'error',
      dismissLabel: 'Dismiss all messages',
      dismissible: true,
      onDismiss: () => setNotifications([]),
      id: uuid4(),
    });
    setNotifications(list);
  };

  const login = () => {
    try {
      Auth.signIn(user, password).then(
        (result) => {
          Auth.currentAuthenticatedUser()
            .then((data) => {
              let decodedToken = jwt_decode(data.signInUserSession.idToken["jwtToken"]);
              console.log("Token : " + JSON.stringify(data.signInUserSession.idToken["jwtToken"]))
              if ((decodedToken["cognito:groups"] != undefined) && (decodedToken["cognito:groups"].length > 0) && (decodedToken["cognito:groups"][0].includes("customer"))) {
                dispatch(storeToken(data.signInUserSession.idToken["jwtToken"]))
                history.push("/");
              }
              else {
                addNotification("User not member of customer group.")
              }
            });
        }).catch(error => {
          console.log("Got error in login function");
          console.log(error);
          addNotification("Incorrect username or password.")
        });
    } catch (error) {
      console.log("Got error in login function");
      console.log(error);
    }
  }

  const signup = () => {

    history.push("/SignUp");
  }

  const confirmSignup = () => {

    history.push("/ConfirmSignUp");
  }

  const updatePassword = () => {

    history.push("/UpdatePassword");
  }

  return (
    <div>
      <Box margin={{ bottom: 'l' }}>
        <div className="back_ground_black">
          <Box padding={{ vertical: 'xxl', horizontal: 's' }}>
            <Grid
              gridDefinition={[
                { colspan: { xl: 6, l: 5, s: 10, xxs: 10 }, offset: { l: 2, xxs: 1 } }
              ]}
            >
              <div className="text_white">
                <SpaceBetween size="xl">
                  <Box variant="h1" fontWeight="bold" padding="n" fontSize="display-l" color="inherit">
                    ###APP_TITLE###
                  </Box>
                  <Box variant="h3" fontWeight="bold">
                    <span className="text_white">
                      This solution demonstrates ###APP_TITLE###.
                    </span>
                  </Box>
                  <Box>
                    <Button disabled="true" href="/Analytics" variant="primary">Open Analytics Dashboard</Button>
                  </Box>
                </SpaceBetween>
              </div>

            </Grid>
          </Box>
        </div>
        <div className="border_black">
          <Box margin={{ top: 's' }} padding={{ top: 'xxl', horizontal: 's' }}>
            <Grid
              gridDefinition={[
                { colspan: 4, offset: 4 }
              ]}
            >
              <div className="border_black">
                <Box margin={{ top: 's', bottom: 'xl' }} padding={{ top: 'xl', horizontal: 'xl' }}>
                  <SpaceBetween size="xl">
                    <div>
                      <Box fontSize="heading-m" fontWeight="normal" variant="h3">
                        User Email:

                        <Input onChange={({ detail }) => setUser(detail.value)}
                          value={user}
                        />
                      </Box>
                    </div>

                    <div>
                      <Box fontSize="heading-m" fontWeight="normal" variant="h3">
                        Password:

                        <Input type="password" onChange={({ detail }) => setPassword(detail.value)}
                          value={password}
                        />

                      </Box>
                    </div>

                    <div>
                      <Grid
                        gridDefinition={[{ colspan: 4 }, { colspan: 4 }, { colspan: 4 }]}
                      >
                        <div>
                          <Box>
                            <Button onClick={({ detail }) => login()} variant="primary">Login</Button>
                          </Box>
                        </div>

                        <div>
                          <Box>
                            <Button onClick={({ detail }) => signup()}>Sign Up</Button>
                          </Box>
                        </div>

                        <div>
                          <Box>
                            <Button onClick={({ detail }) => confirmSignup()}>Verify</Button>
                          </Box>
                        </div>

                        <div>
                          <Box>
                            <Button onClick={({ detail }) => updatePassword()}>Update Password</Button>
                          </Box>
                        </div>

                      </Grid>
                    </div>

                    <div>
                      <Flashbar items={notifications} />
                    </div>

                  </SpaceBetween>
                </Box>
              </div>

            </Grid>
          </Box>
          <Box margin={{ top: 's' }} padding={{ top: 'xxl', horizontal: 's' }}>
          </Box>
        </div>
      </Box>

    </div>
  );
}



