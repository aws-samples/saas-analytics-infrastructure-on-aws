// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

import React from 'react';
import { useSelector } from "react-redux";
import { ReduxRoot } from "../../interfaces";
import { CustomAppLayout } from "../common/app-layout";
import { Navigation } from "../common/navigation";
import { BreadcrumbGroup, HelpPanel } from "@cloudscape-design/components";
import SpaceBetween from "@cloudscape-design/components/space-between";
import Box from "@cloudscape-design/components/box";
import ColumnLayout from "@cloudscape-design/components/column-layout";

export default class InputFileDetailView extends React.Component {

  render() {
    return (
        <CustomAppLayout
            navigation={<Navigation activeHref="/InputFile"/>}
            navigationOpen={true}
            breadcrumbs={<Breadcrumbs />}
            content={<InputFileDetail />}
            contentType="default"
            tools={<ToolsContent />}
            toolsHide={false}
        />

    );
  }
}

export const resourcesBreadcrumbs = [
  {
    text: 'Input Files',
    href: '/InputFiles',
  },
  {
    text: 'Input File Detail',
    href: '/InputFile',
  },
];

export const Breadcrumbs = () => (
    <BreadcrumbGroup items={resourcesBreadcrumbs} expandAriaLabel="Show path" ariaLabel="Breadcrumbs" />
);

export const ToolsContent = () => (
    <HelpPanel
        header={<h2>Input File</h2>}
        footer={
          <>
          </>
        }
    >
      <p>
        View details of an input file.
      </p>
    </HelpPanel>
);

function InputFileDetail (props: any) {

  const customerFile = useSelector( (state:ReduxRoot) => {
    return state.reducerState.customerFile
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
                    <div>{customerFile.name}</div>
                  </div>
                </div>

                <div className="awsui-util-spacing-v-s">
                  <div>
                    <Box variant="awsui-key-label">Type</Box>
                    <div>{customerFile.type}</div>
                  </div>
                </div>

                <div className="awsui-util-spacing-v-s">
                  <div>
                    <Box variant="awsui-key-label">Date</Box>
                    <div>{customerFile.date}</div>
                  </div>
                </div>

                <div className="awsui-util-spacing-v-s">
                  <div>
                    <Box variant="awsui-key-label">Customer</Box>
                    <div>{customerFile.customer}</div>
                  </div>
                </div>

                <div className="awsui-util-spacing-v-s">
                  <div>
                    <Box variant="awsui-key-label">Dataset</Box>
                    <div>{customerFile.dataset}</div>
                  </div>
                </div>

              </ColumnLayout>

            </SpaceBetween>

          </Box>
        </div>
      </div>
  );
}


