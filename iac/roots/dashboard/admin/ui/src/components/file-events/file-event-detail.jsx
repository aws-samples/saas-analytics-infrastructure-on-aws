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

export default class FileEventDetailView extends React.Component {

  render() {
    return (
        <CustomAppLayout
            navigation={<Navigation activeHref="/FileEvent"/>}
            navigationOpen={true}
            breadcrumbs={<Breadcrumbs />}
            content={<FileEventDetail />}
            contentType="default"
            tools={<ToolsContent />}
            toolsHide={false}
        />

    );
  }
}

export const resourcesBreadcrumbs = [
  {
    text: 'FileEvents',
    href: '/FileEvents',
  },
  {
    text: 'FileEvent',
    href: '/FileEvent',
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

function FileEventDetail (props: any) {

  const fileEvent = useSelector( (state:ReduxRoot) => {
    return state.reducerState.fileEvent
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
                    <Box variant="awsui-key-label">Customer</Box>
                    <div>{fileEvent.customer}</div>
                  </div>
                </div>

                <div className="awsui-util-spacing-v-s">
                  <div>
                    <Box variant="awsui-key-label">Date</Box>
                    <div>{fileEvent.date}</div>
                  </div>
                </div>

                <div className="awsui-util-spacing-v-s">
                  <div>
                    <Box variant="awsui-key-label">Name</Box>
                    <div>{fileEvent.name}</div>
                  </div>
                </div>

                <div className="awsui-util-spacing-v-s">
                  <div>
                    <Box variant="awsui-key-label">Dataset</Box>
                    <div>{fileEvent.dataset}</div>
                  </div>
                </div>

                <div className="awsui-util-spacing-v-s">
                  <div>
                    <Box variant="awsui-key-label">Rows</Box>
                    <div>{fileEvent.rows}</div>
                  </div>
                </div>

                <div className="awsui-util-spacing-v-s">
                  <div>
                    <Box variant="awsui-key-label">Columns</Box>
                    <div>{fileEvent.columns}</div>
                  </div>
                </div>

                <div className="awsui-util-spacing-v-s">
                  <div>
                    <Box variant="awsui-key-label">Bytes</Box>
                    <div>{fileEvent.bytes}</div>
                  </div>
                </div>

              </ColumnLayout>

            </SpaceBetween>

          </Box>
        </div>
      </div>
  );
}


