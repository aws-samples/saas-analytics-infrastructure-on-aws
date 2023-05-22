// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

import React from 'react';
import {useSelector} from "react-redux";
import {ReduxRoot} from "../../interfaces";
import {CustomAppLayout} from "../common/app-layout";
import {Navigation} from "../common/navigation";
import {BreadcrumbGroup, HelpPanel} from "@cloudscape-design/components";
import SpaceBetween from "@cloudscape-design/components/space-between";
import Box from "@cloudscape-design/components/box";
import ColumnLayout from "@cloudscape-design/components/column-layout";

export default class AnalyticsEventDetailView extends React.Component {

  render() {
    return (
        <CustomAppLayout
            navigation={<Navigation activeHref="/AnalyticsEvent"/>}
            navigationOpen={true}
            breadcrumbs={<Breadcrumbs />}
            content={<AnalyticsEventDetail />}
            contentType="default"
            tools={<ToolsContent />}
            toolsHide={false}
            // labels={appLayoutNavigationLabels}
        />

    );
  }
}

export const resourcesBreadcrumbs = [
  {
    text: 'AnalyticsEvents',
    href: '/AnalyticsEvents',
  },
  {
    text: 'AnalyticsEvent',
    href: '/AnalyticsEvent',
  },
];

export const Breadcrumbs = () => (
    <BreadcrumbGroup items={resourcesBreadcrumbs} expandAriaLabel="Show path" ariaLabel="Breadcrumbs" />
);

export const ToolsContent = () => (
    <HelpPanel
        header={<h2>File Events</h2>}
        footer={
          <>
          </>
        }
    >
      <p>
        View details of a file event.
      </p>
    </HelpPanel>
);

function AnalyticsEventDetail (props: any) {

  const analyticsEvent = useSelector( (state:ReduxRoot) => {
    return state.reducerState.analyticsEvent
  });

  return (
      <div>

        <div>
          <Box margin={{ top: 's', bottom: 's' }} padding={{ top: 's', bottom: 's', horizontal: 'xl' }}>
          </Box>
        </div>

        <div className="border_black">

          <Box margin={{ top: 's', bottom: 's' }} padding={{ top: 'xxl', bottom: 'xxl', horizontal: 'xl' }}>

            <SpaceBetween size="xl">

              <ColumnLayout columns={1} variant="text-grid">

                <div className="awsui-util-spacing-v-s">
                  <div>
                    <Box variant="awsui-key-label">Date</Box>
                    <div>{analyticsEvent.date}</div>
                  </div>
                </div>

                <div className="awsui-util-spacing-v-s">
                  <div>
                    <Box variant="awsui-key-label">Time</Box>
                    <div>{analyticsEvent.time}</div>
                  </div>
                </div>

                <div className="awsui-util-spacing-v-s">
                  <div>
                    <Box variant="awsui-key-label">Duration</Box>
                    <div>{analyticsEvent.duration}</div>
                  </div>
                </div>

                <div className="awsui-util-spacing-v-s">
                  <div>
                    <Box variant="awsui-key-label">Files</Box>
                    <div>{analyticsEvent.files}</div>
                  </div>
                </div>

                <div className="awsui-util-spacing-v-s">
                  <div>
                    <Box variant="awsui-key-label">Executor</Box>
                    <div>{analyticsEvent.executor}</div>
                  </div>
                </div>

              </ColumnLayout>

            </SpaceBetween>

          </Box>
        </div>
      </div>
  );
}


