// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
import React, { useEffect, useState } from 'react';
import PropertyFilter from "@cloudscape-design/components/property-filter";
import { useCollection } from '@cloudscape-design/collection-hooks';
import { COLUMN_DEFINITIONS, FILTERING_PROPERTIES, PROPERTY_FILTERING_I18N_CONSTANTS, DEFAULT_PREFERENCES, Preferences } from './analytics-table-config';
import {
  BreadcrumbGroup,
  Button,
  Flashbar,
  HelpPanel,
  Pagination,
  SpaceBetween,
  Table
} from '@cloudscape-design/components';
import { CustomAppLayout } from '../common/app-layout';
import { Navigation } from '../common/navigation';
import { TableEmptyState, TableHeader, TableNoMatchState } from '../common/table-components';
import {paginationLabels, distributionSelectionLabels} from '../../common/labels';
import { getFilterCounterText } from '../../common/tableCounterStrings';
import '../../styles/base.scss';
import { useColumnWidths } from '../common/use-column-widths';
import { useLocalStorage } from '../../common/localStorage';
import { IAnalytics, ReduxRoot } from "../../interfaces";

import { useDispatch, useSelector } from "react-redux";
import { storeAnalytics } from "../../redux/actions";
import { useHistory } from "react-router-dom";
import {executeAnalytics1, getAnalytics} from "../../data";
import {v4 as uuid4} from "uuid";

export const resourcesBreadcrumbs = [
  {
    text: 'Analytics',
    href: '/Analytics',
  },
];

export const Breadcrumbs = () => (
    <BreadcrumbGroup items={resourcesBreadcrumbs} expandAriaLabel="Show path" ariaLabel="Breadcrumbs" />
);

export const FullPageHeader = ({
                                 resourceName = 'Analytics',
                                 createButtonText = 'Create analytics',
                                 addNotification,
                                 ...props
                               }) => {
  const isOnlyOneSelected = props.selectedItems.length === 1;

  const history = useHistory();

  const token = useSelector( (state:ReduxRoot) => {
    return state.reducerState.token
  });

  const onOpenClick = () => {
    history.push("/AnalyticsDetail");
  }

  const executeAnalytics = async () => {

    try {
      addNotification("Initiated analytics execution.")

      await executeAnalytics1(token);

      await Promise.resolve();
      
      addNotification("Completed analytic executions.")
    }
    catch (err) {
      console.log("Got Error Message: " + err.toString());
    }
  }

  return (
      <TableHeader
          variant="awsui-h1-sticky"
          title={resourceName}
          actionButtons={
            <SpaceBetween size="xs" direction="horizontal">
              <Button onClick={onOpenClick} disabled={!isOnlyOneSelected}>View details</Button>
              <Button onClick={executeAnalytics} variant="primary">Execute</Button>
            </SpaceBetween>
          }
          {...props}
      />
  );
};

export const ToolsContent = () => (
    <HelpPanel
        header={<h2>Analytics</h2>}
        footer={
          <>
          </>
        }
    >
      <p>
        View all your analytics.
      </p>
    </HelpPanel>
);

function TableContent({updateTools, addNotification }) {

  const dispatch = useDispatch();

  const token = useSelector( (state:ReduxRoot) => {
    return state.reducerState.token
  });

  const [analytics, setAnalytics] = useState([]);
  const [selectedAnalytics, setSelectedAnalytics] = useState([]);

  const [columnDefinitions, saveWidths] = useColumnWidths('React-Table-Widths', COLUMN_DEFINITIONS);
  const [preferences, setPreferences] = useLocalStorage('React-DistributionsTable-Preferences', DEFAULT_PREFERENCES);

  const { items, actions, filteredItemsCount, collectionProps, paginationProps, propertyFilterProps } = useCollection(
      analytics,
    {
      propertyFiltering: {
        filteringProperties: FILTERING_PROPERTIES,
        empty: <TableEmptyState resourceName="Analytic" />,
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

  const getAllAnalytics = async () => {

    try {

      await getAnalytics(token).then(
          (result: IAnalytics[]) => {
            //console.log("Received Analytics :" + JSON.stringify(result))
            setAnalytics(result);
          });

      await Promise.resolve();

    }
    catch (err) {
      console.log("Got Error Message: " + err.toString());
    }
  }

  useEffect( () => {

    getAllAnalytics().then(() => console.log("getAnalytics() completed."));
  }, []);

  const selectAnalytics = (analytics: IAnalytics) => {
    dispatch(storeAnalytics(analytics?analytics: {}));
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
          selectedItems={selectedAnalytics}
          totalItems={analytics}
          updateTools={updateTools}
          serverSide={false}
          addNotification={addNotification}
        />
      }
      loadingText="Loading analytics"
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
      selectedItems={selectedAnalytics}
      onSelectionChange={evt => {setSelectedAnalytics(evt.detail.selectedItems); selectAnalytics(evt.detail.selectedItems[0])}}
    />
  );
}

function AnalyticsTableView() {
  const [columnDefinitions, saveWidths] = useColumnWidths('React-TableServerSide-Widths', COLUMN_DEFINITIONS);
  const [toolsOpen, setToolsOpen] = useState(false);
  const [notifications, setNotifications] = useState([]);

  const addNotification = (message: string) => {
    const list = []
    for (let notification of notifications) {
      list.push(notification)
    }
    list.push({
      type: 'success',
      content: message,
      statusIconAriaLabel: 'success',
      dismissLabel: 'Dismiss all messages',
      dismissible: true,
      onDismiss: () => setNotifications([]),
      id: uuid4(),
    });
    setNotifications(list);
  };

  return (
    <CustomAppLayout
      navigation={<Navigation activeHref="/Analytics" />}
      notifications={<Flashbar items={notifications} />}
      breadcrumbs={<Breadcrumbs />}
      content={
        <TableContent
          columnDefinitions={columnDefinitions}
          saveWidths={saveWidths}
          updateTools={() => setToolsOpen(true)}
          addNotification={addNotification}
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

export default AnalyticsTableView;