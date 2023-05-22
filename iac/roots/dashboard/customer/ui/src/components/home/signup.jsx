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
import { useDispatch } from "react-redux";
import { v4 as uuid4 } from "uuid";

export default class SignUpView extends React.Component {
  render() {
    return (
      <CustomAppLayout
        navigation={<Navigation activeHref="/" />}
        navigationOpen={false}
        content={<SignUpContent />}
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
export function SignUpContent() {

  const history = useHistory();

  const [user, setUser] = React.useState("");
  // const [phone, setPhone] = React.useState("");
  const [password, setPassword] = React.useState("");
  const [notifications, setNotifications] = useState([]);

  const approved_participants = ["morganstanley.com", "ms.com", "amazon.com"]

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

  const signup = () => {
    try {
      if (is_approved_participant(approved_participants, user)) {

        Auth.signUp({
          username: user,
          password: password,
          attributes: {
            email: user
          }
        }
        ).then((result) => {
          history.push("/ConfirmSignup");
        }).catch(error => {
          console.log("Got error in signup function");
          console.log(error);
          addNotification("Error during sign up.")
        });

      } else {
        addNotification("Not an approved participant.")
      }

    } catch (error) {
      console.log("Got error in signup function");
      console.log(error);
    }
  }

  const confirmSignup = () => {

    history.push("/ConfirmSignUp");
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
                        gridDefinition={[{ colspan: 4 }, { colspan: 6 }]}
                      >

                        <div>
                          <Box>
                            <Button onClick={({ detail }) => signup()} variant="primary">Sign Up</Button>
                          </Box>
                        </div>

                        <div>
                          <Box>
                            <Button onClick={({ detail }) => confirmSignup()} variant="primary">Verify</Button>
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

function is_approved_participant(participants: string[], participant: string) {

  for (let item of participants) {

    if (participant.endsWith(item)) {

      return true;
    }
  }

  return false;
}

