// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
import React, { useEffect, useState } from 'react';
import PropertyFilter from "@cloudscape-design/components/property-filter";
import { useCollection } from '@cloudscape-design/collection-hooks';
import { COLUMN_DEFINITIONS, FILTERING_PROPERTIES, PROPERTY_FILTERING_I18N_CONSTANTS, DEFAULT_PREFERENCES, Preferences } from './customer-table-config';
import {
  BreadcrumbGroup,
  Button,
  HelpPanel,
  Pagination,
  SpaceBetween,
  Table
} from '@cloudscape-design/components';
import { CustomAppLayout } from '../common/app-layout';
import { Navigation } from '../common/navigation';
import { Notifications } from '../common/notifications';
import { TableEmptyState, TableHeader, TableNoMatchState } from '../common/table-components';

import {paginationLabels, distributionSelectionLabels} from '../../common/labels';
import { getFilterCounterText } from '../../common/tableCounterStrings';
import '../../styles/base.scss';
import { useColumnWidths } from '../common/use-column-widths';
import { useLocalStorage } from '../../common/localStorage';
import { ICustomer, ReduxRoot } from "../../interfaces";

import { useDispatch, useSelector } from "react-redux";
import { storeCustomer } from "../../redux/actions";
import { useHistory } from "react-router-dom";
import { getCustomers } from "../../data";

export const resourcesBreadcrumbs = [
  {
    text: 'Customers',
    href: '/Customers',
  },
];

export const Breadcrumbs = () => (
    <BreadcrumbGroup items={resourcesBreadcrumbs} expandAriaLabel="Show path" ariaLabel="Breadcrumbs" />
);

export const FullPageHeader = ({
                                 resourceName = 'Customers',
                                 createButtonText = 'Create customer',
                                 ...props
                               }) => {
  const isOnlyOneSelected = props.selectedItems.length === 1;

  const history = useHistory();

  const onOpenClick = () => {
    history.push("/CustomerDetail");
  }

  return (
      <TableHeader
          variant="awsui-h1-sticky"
          title={resourceName}
          actionButtons={
            <SpaceBetween size="xs" direction="horizontal">
              <Button onClick={onOpenClick} disabled={!isOnlyOneSelected}>View details</Button>
            </SpaceBetween>
          }
          {...props}
      />
  );
};

export const ToolsContent = () => (
    <HelpPanel
        header={<h2>Customers</h2>}
        footer={
          <>
          </>
        }
    >
      <p>
        View all your customers.
      </p>
    </HelpPanel>
);

function TableContent({updateTools }) {

  const dispatch = useDispatch();

  const token = useSelector( (state:ReduxRoot) => {
    return state.reducerState.token
  });

  const [customers, setCustomers] = useState([]);
  const [selectedCustomers, setSelectedCustomers] = useState([]);

  const [columnDefinitions, saveWidths] = useColumnWidths('React-Table-Widths', COLUMN_DEFINITIONS);
  const [preferences, setPreferences] = useLocalStorage('React-DistributionsTable-Preferences', DEFAULT_PREFERENCES);

  const { items, actions, filteredItemsCount, collectionProps, paginationProps, propertyFilterProps } = useCollection(
      customers,
    {
      propertyFiltering: {
        filteringProperties: FILTERING_PROPERTIES,
        empty: <TableEmptyState resourceName="Customer" />,
        noMatch: (
            <TableNoMatchState
                onClearFilter={() => {
                  actions.setPropertyFiltering({ tokens: [], operation: 'and' });
                }}
            />
        ),
      },
      pagination: { pageSize: preferences.pageSize },
      sorting: { defaultState: { sortingColumn: columnDefinitions[0] } },
      selection: {},
    }
  );

  const getAllCustomers = async () => {

    try {

      await getCustomers(token).then(
          (result: ICustomer[]) => {
            setCustomers(result);
          });

      await Promise.resolve();

    }
    catch (err) {
      console.log("Got Error Message: " + err.toString());
    }
  }

  useEffect( () => {

    getAllCustomers().then(() => console.log("getAllCustomers() completed."));
  }, []);

  const selectCustomer = (customer: ICustomer) => {
    dispatch(storeCustomer(customer?customer: {}));
  }

  return (
    <Table
      {...collectionProps}
      items={items}
      columnDefinitions={columnDefinitions}
      visibleColumns={preferences.visibleContent}
      ariaLabels={distributionSelectionLabels}
      selectionType="single"
      variant="full-page"
      stickyHeader={true}
      resizableColumns={true}
      wrapLines={preferences.wrapLines}
      onColumnWidthsChange={saveWidths}
      header={
        <FullPageHeader
          selectedItems={selectedCustomers}
          totalItems={customers}
          updateTools={updateTools}
          serverSide={false}
        />
      }
      loadingText="Loading customers"
      filter={
        <PropertyFilter
          i18nStrings={PROPERTY_FILTERING_I18N_CONSTANTS}
          {...propertyFilterProps}
          countText={getFilterCounterText(filteredItemsCount)}
          expandToViewport={true}
        />
      }
      pagination={<Pagination {...paginationProps} ariaLabels={paginationLabels} />}
      preferences={<Preferences preferences={preferences} setPreferences={setPreferences} />}
      selectedItems={selectedCustomers}
      onSelectionChange={evt => {setSelectedCustomers(evt.detail.selectedItems); selectCustomer(evt.detail.selectedItems[0])}}
    />
  );
}

function CustomerTableView() {
  const [columnDefinitions, saveWidths] = useColumnWidths('React-TableServerSide-Widths', COLUMN_DEFINITIONS);
  const [toolsOpen, setToolsOpen] = useState(false);

  return (
    <CustomAppLayout
      navigation={<Navigation activeHref="/Customers" />}
      notifications={<Notifications successNotification={false} />}
      breadcrumbs={<Breadcrumbs />}
      content={
        <TableContent
          columnDefinitions={columnDefinitions}
          saveWidths={saveWidths}
          updateTools={() => setToolsOpen(true)}
        />
      }
      contentType="table"
      tools={<ToolsContent />}
      toolsOpen={toolsOpen}
      onToolsChange={({ detail}) => setToolsOpen(detail.open)}
      stickyNotifications={true}
    />
  );
}

export default CustomerTableView;