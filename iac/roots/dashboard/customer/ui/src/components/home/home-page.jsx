import React from 'react';
import Diagram from './diagram.jpg';

import '../common/styles.css';
import '../../styles/base.scss';
import {
  Box,
  Button,
  Container,
  Grid,
  HelpPanel,
  SpaceBetween
} from "@cloudscape-design/components";
import { Navigation } from "../common/navigation";
import { CustomAppLayout } from "../common/app-layout";
import Cognito from "./cognito";
import { useHistory } from "react-router-dom";

export default class HomepageView extends React.Component {
  render() {
    return (
      <CustomAppLayout
        navigation={<Navigation activeHref="/" />}
        navigationOpen={false}
        content={<HomepageContent />}
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
export function HomepageContent() {

  const history = useHistory();

  const openAnalytics = () => {

    history.push("/InputFiles")
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
                    <Button onClick={({ detail }) => openAnalytics()} variant="primary">Open Analytics Dashboard</Button>
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
                { colspan: { xl: 6, l: 5, s: 10, xxs: 10 }, offset: { l: 4, xxs: 1 } }
              ]}
            >
              <div>
                <SpaceBetween size="l">
                  <div>
                    <Box fontSize="heading-xl" fontWeight="normal" variant="h2">
                      Architecture
                    </Box>
                    <Container>
                      <img src={Diagram} width="100%" height="100%" alt="" />
                    </Container>
                  </div>

                </SpaceBetween>
              </div>

            </Grid>
          </Box>
          <Box margin={{ top: 's' }} padding={{ top: 'xxl', horizontal: 's' }}>
          </Box>
        </div>
      </Box>
      <Cognito />
    </div>
  );
}



