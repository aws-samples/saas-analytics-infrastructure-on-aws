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

export default class CustomerDetailView extends React.Component {

  render() {
    return (
        <CustomAppLayout
            navigation={<Navigation activeHref="/Customer"/>}
            navigationOpen={true}
            breadcrumbs={<Breadcrumbs />}
            content={<CustomerDetail />}
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
    text: 'Customers',
    href: '/Customers',
  },
  {
    text: 'Customer',
    href: '/Customer',
  },
];

export const Breadcrumbs = () => (
    <BreadcrumbGroup items={resourcesBreadcrumbs} expandAriaLabel="Show path" ariaLabel="Breadcrumbs" />
);

export const ToolsContent = () => (
    <HelpPanel
        header={<h2>Customers</h2>}
        footer={
          <>
          </>
        }
    >
      <p>
        View details of a customer.
      </p>
    </HelpPanel>
);

function CustomerDetail (props: any) {

  const customer = useSelector( (state:ReduxRoot) => {
    return state.reducerState.customer
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
                    <Box variant="awsui-key-label">ID</Box>
                    <div>{customer.id}</div>
                  </div>
                </div>

              </ColumnLayout>

            </SpaceBetween>

          </Box>
        </div>
      </div>
  );
}


