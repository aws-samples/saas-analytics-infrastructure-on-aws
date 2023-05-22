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
import { Auth } from "aws-amplify";
import { useHistory } from "react-router-dom";
import { v4 as uuid4 } from "uuid";
import { getCustomerInputFiles, updatePassword } from "../../data";
import { ICustomerFile, ReduxRoot } from "../../interfaces";
import { useSelector } from "react-redux";
import jwt_decode from "jwt-decode";

export default class UpdatePasswordView extends React.Component {
  render() {
    return (
      <CustomAppLayout
        navigation={<Navigation activeHref="/" />}
        navigationOpen={false}
        content={<UpdatePasswordContent />}
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
export function UpdatePasswordContent() {

  const history = useHistory();

  const [email, setEmail] = React.useState("");
  const [oldPassword, setOldPassword] = React.useState("");
  const [newPassword, setNewPassword] = React.useState("");
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

  const updatePasswordWithAuth = async () => {

    try {
      Auth.signIn(email, oldPassword).then(
        (result) => {
          Auth.currentAuthenticatedUser()
            .then((user) => {
              Auth.changePassword(user, oldPassword, newPassword).then((data) => {
                history.push("/Login");
              }
              ).catch(error => {
                console.log("Got error in password update function");
                console.log(error);
                addNotification("Error during password update.")
              })
            })
        }).catch(error => {
          console.log("Incorrect old password");
          console.log(error);
          addNotification("Incorrect old password.")
        });
    }
    catch (err) {
      console.log("Got Error Message: " + err.toString());
    }
  }

  const updatePasswordWithAPI = async () => {

    try {
      Auth.signIn(email, oldPassword).then(
        (result) => {
          Auth.currentAuthenticatedUser()
            .then((user) => {
              let token = user.signInUserSession.idToken["jwtToken"]
              let decodedToken = jwt_decode(token);
              let user_pool = get_user_pool(decodedToken["iss"])
              console.log("Token: " + token);
              console.log("User Pool: " + user_pool);
              console.log("Password: " + newPassword);
              updatePassword(token, user_pool, newPassword).then((data) => {
                history.push("/Login");
              });
            })
        }).catch(error => {
          console.log("Incorrect old password");
          console.log(error);
          addNotification("Incorrect old password.")
        });
    }
    catch (err) {
      console.log("Got Error Message: " + err.toString());
      addNotification("Error with password update.");
    }

    // try {
    //   if (authenticated) {
    //     await updatePassword(token, Auth.Credentials.getCredSource().id, newPassword);
    //     await Promise.resolve();
    //   }
    //   else {
    //     console.log("User is not authenticated");
    //     addNotification("User is not authenticated.");
    //   }
    // }
    // catch (err) {
    //     console.log("Got Error Message: " + err.toString());
    // }
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

                        <Input onChange={({ detail }) => setEmail(detail.value)}
                          value={email}
                        />
                      </Box>
                    </div>

                    <div>
                      <Box fontSize="heading-m" fontWeight="normal" variant="h3">
                        Old Password:

                        <Input type="password" onChange={({ detail }) => setOldPassword(detail.value)}
                          value={oldPassword}
                        />

                      </Box>
                    </div>

                    <div>
                      <Box fontSize="heading-m" fontWeight="normal" variant="h3">
                        New Password:

                        <Input type="password" onChange={({ detail }) => setNewPassword(detail.value)}
                          value={newPassword}
                        />

                      </Box>
                    </div>

                    <div>
                      <Box>
                        <Button onClick={({ detail }) => updatePasswordWithAPI()} variant="primary">Update Password</Button>
                      </Box>
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

function get_user_pool(iss: string) {

  let tokens = iss.split("/")
  if (tokens.length > 0) {
    return tokens[tokens.length - 1]
  }

  return "";
}


