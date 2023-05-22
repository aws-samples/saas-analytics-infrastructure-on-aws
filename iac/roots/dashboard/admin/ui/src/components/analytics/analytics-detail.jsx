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

export default class AnalyticsDetailView extends React.Component {

  render() {
    return (
        <CustomAppLayout
            navigation={<Navigation activeHref="/AnalyticsDetail"/>}
            navigationOpen={true}
            breadcrumbs={<Breadcrumbs />}
            content={<AnalyticsDetail />}
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
    text: 'Analytics',
    href: '/Analytics',
  },
  {
    text: 'Analytics Detail',
    href: '/AnalyticsDetail',
  },
];

export const Breadcrumbs = () => (
    <BreadcrumbGroup items={resourcesBreadcrumbs} expandAriaLabel="Show path" ariaLabel="Breadcrumbs" />
);

export const ToolsContent = () => (
    <HelpPanel
        header={<h2>Analytics</h2>}
        footer={
          <>
          </>
        }
    >
      <p>
        View details of a analytics.
      </p>
    </HelpPanel>
);

function AnalyticsDetail (props: any) {

  const analytics = useSelector( (state:ReduxRoot) => {
    return state.reducerState.analytics
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
                    <Box variant="awsui-key-label">Name</Box>
                    <div>{analytics.name}</div>
                  </div>
                </div>

                <div className="awsui-util-spacing-v-s">
                  <div>
                    <Box variant="awsui-key-label">Description</Box>
                    <div>
                      {analytics.description}
                    </div>
                  </div>
                </div>

              </ColumnLayout>

            </SpaceBetween>

          </Box>
        </div>
      </div>
  );
}


