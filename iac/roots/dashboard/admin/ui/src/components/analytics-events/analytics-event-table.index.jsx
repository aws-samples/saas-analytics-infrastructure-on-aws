// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
import React, { useEffect, useState } from 'react';
import PropertyFilter from "@cloudscape-design/components/property-filter";
import { useCollection } from '@cloudscape-design/collection-hooks';
import { COLUMN_DEFINITIONS, FILTERING_PROPERTIES, PROPERTY_FILTERING_I18N_CONSTANTS, DEFAULT_PREFERENCES, Preferences } from './analytics-event-table-config';
import {
  BreadcrumbGroup,
  Button,
  HelpPanel,
  Pagination,
  SpaceBetween,
  Grid,
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
import { IAnalyticsEvent, ReduxRoot } from "../../interfaces";

import { useDispatch, useSelector } from "react-redux";
import { storeAnalyticsEvent} from "../../redux/actions";
import { useHistory } from "react-router-dom";
import { getAnalyticsEvents} from "../../data";
import DatePicker from "@cloudscape-design/components/date-picker";

export const resourcesBreadcrumbs = [
  {
    text: 'AnalyticsEvents',
    href: '/AnalyticsEvents',
  },
];

export const Breadcrumbs = () => (
    <BreadcrumbGroup items={resourcesBreadcrumbs} expandAriaLabel="Show path" ariaLabel="Breadcrumbs" />
);

export const FullPageHeader = ({
                                 resourceName = 'Analytics Events',
                                 createButtonText = 'Create an event',
                                 ...props
                               }) => {
  const isOnlyOneSelected = props.selectedItems.length === 1;

  const history = useHistory();

  const onOpenClick = () => {
    history.push("/AnalyticsEvent");
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
        header={<h2>Analytics Events</h2>}
        footer={
          <>
          </>
        }
    >
      <p>
        View all your analytics events.
      </p>
    </HelpPanel>
);

function TableContent({updateTools }) {

  const dispatch = useDispatch();

  const token = useSelector( (state:ReduxRoot) => {
    return state.reducerState.token
  });

  const [date, setDate] = useState("");
  const [analyticsEvents, setAnalyticsEvents] = useState([]);
  const [selectedAnalyticsEvents, setSelectedAnalyticsEvents] = useState([]);

  const [columnDefinitions, saveWidths] = useColumnWidths('React-Table-Widths', COLUMN_DEFINITIONS);
  const [preferences, setPreferences] = useLocalStorage('React-DistributionsTable-Preferences', DEFAULT_PREFERENCES);

  const { items, actions, filteredItemsCount, collectionProps, paginationProps, propertyFilterProps } = useCollection(
      analyticsEvents,
    {
      propertyFiltering: {
        filteringProperties: FILTERING_PROPERTIES,
        empty: <TableEmptyState resourceName="Analytics Events" />,
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

  const getAllAnalyticsEvents = async () => {

    try {

      await getAnalyticsEvents(token, date).then(
          (result: IAnalyticsEvent[]) => {
            setAnalyticsEvents(result);
          });

      await Promise.resolve();

    }
    catch (err) {
      console.log("Got Error Message: " + err.toString());
    }
  }

  // useEffect( () => {
  //
  //   getAllAnalyticsEvents().then(() => console.log("getAllAnalyticsEvents() completed."));
  // }, []);

  const selectAnalyticsEvent = (analyticsEvent: IAnalyticsEvent) => {
    dispatch(storeAnalyticsEvent(analyticsEvent?analyticsEvent: {}));
  }

  const onGetReport = () => {
    getAllAnalyticsEvents().then(() => console.log("getAllAnalyticsEvents() completed."));
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
            selectedItems={selectedAnalyticsEvents}
            totalItems={analyticsEvents}
            updateTools={updateTools}
            serverSide={false}
          />
        }
        loadingText="Loading analytics events"
        filter={
          <Grid
              gridDefinition={[{ colspan: 6 }, { colspan: 4 }, { colspan: 2 }]}
          >
            <PropertyFilter
              i18nStrings={PROPERTY_FILTERING_I18N_CONSTANTS}
              {...propertyFilterProps}
              countText={getFilterCounterText(filteredItemsCount)}
              expandToViewport={true}
            />
            <DatePicker
                onChange={({ detail }) => setDate(detail.value)}
                value={date}
                openCalendarAriaLabel={selectedDate =>
                    "Choose search date" +
                    (selectedDate
                        ? `, selected date is ${selectedDate}`
                        : "")
                }
                nextMonthAriaLabel="Next month"
                placeholder="YYYY/MM/DD"
                previousMonthAriaLabel="Previous month"
                todayAriaLabel="Today"
            />
            <Button onClick={onGetReport} variant="primary">Get report</Button>
          </Grid>
        }
        pagination={<Pagination {...paginationProps} ariaLabels={paginationLabels} />}
        preferences={<Preferences preferences={preferences} setPreferences={setPreferences} />}
        selectedItems={selectedAnalyticsEvents}
        onSelectionChange={evt => {setSelectedAnalyticsEvents(evt.detail.selectedItems); selectAnalyticsEvent(evt.detail.selectedItems[0])}}
      />

  );
}

function AnalyticsEventTableView() {
  const [columnDefinitions, saveWidths] = useColumnWidths('React-TableServerSide-Widths', COLUMN_DEFINITIONS);
  const [toolsOpen, setToolsOpen] = useState(false);

  return (
    <CustomAppLayout
      navigation={<Navigation activeHref="/AnalyticsEvents" />}
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

export default AnalyticsEventTableView;