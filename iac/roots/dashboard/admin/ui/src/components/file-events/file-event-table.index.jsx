// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
import React, { useEffect, useState } from 'react';
import PropertyFilter from "@cloudscape-design/components/property-filter";
import { useCollection } from '@cloudscape-design/collection-hooks';
import { COLUMN_DEFINITIONS, FILTERING_PROPERTIES, PROPERTY_FILTERING_I18N_CONSTANTS, DEFAULT_PREFERENCES, Preferences } from './file-event-table-config';
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
import { IFileEvent, ReduxRoot } from "../../interfaces";

import { useDispatch, useSelector } from "react-redux";
import { storeFileEvent} from "../../redux/actions";
import { useHistory } from "react-router-dom";
import { getFileEvents} from "../../data";

export const resourcesBreadcrumbs = [
  {
    text: 'FileEvents',
    href: '/FileEvents',
  },
];

export const Breadcrumbs = () => (
    <BreadcrumbGroup items={resourcesBreadcrumbs} expandAriaLabel="Show path" ariaLabel="Breadcrumbs" />
);

export const FullPageHeader = ({
                                 resourceName = 'File Events',
                                 createButtonText = 'Create an event',
                                 ...props
                               }) => {
  const isOnlyOneSelected = props.selectedItems.length === 1;

  const history = useHistory();

  const onOpenClick = () => {
    history.push("/FileEvent");
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
        header={<h2>File Events</h2>}
        footer={
          <>
          </>
        }
    >
      <p>
        View all your file events.
      </p>
    </HelpPanel>
);

function TableContent({updateTools }) {

  const dispatch = useDispatch();

  const token = useSelector( (state:ReduxRoot) => {
    return state.reducerState.token
  });

  const [fileEvents, setFileEvents] = useState([]);
  const [selectedFileEvents, setSelectedFileEvents] = useState([]);

  const [columnDefinitions, saveWidths] = useColumnWidths('React-Table-Widths', COLUMN_DEFINITIONS);
  const [preferences, setPreferences] = useLocalStorage('React-DistributionsTable-Preferences', DEFAULT_PREFERENCES);

  const { items, actions, filteredItemsCount, collectionProps, paginationProps, propertyFilterProps } = useCollection(
      fileEvents,
    {
      propertyFiltering: {
        filteringProperties: FILTERING_PROPERTIES,
        empty: <TableEmptyState resourceName="File Events" />,
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

  const getAllFileEvents = async () => {

    try {

      await getFileEvents(token).then(
          (result: IFileEvent[]) => {
            setFileEvents(result);
          });

      await Promise.resolve();

    }
    catch (err) {
      console.log("Got Error Message: " + err.toString());
    }
  }

  useEffect( () => {

    getAllFileEvents().then(() => console.log("getAllFileEvents() completed."));
  }, []);

  const selectFileEvent = (fileEvent: IFileEvent) => {
    dispatch(storeFileEvent(fileEvent?fileEvent: {}));
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
          selectedItems={selectedFileEvents}
          totalItems={fileEvents}
          updateTools={updateTools}
          serverSide={false}
        />
      }
      loadingText="Loading file events"
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
      selectedItems={selectedFileEvents}
      onSelectionChange={evt => {setSelectedFileEvents(evt.detail.selectedItems); selectFileEvent(evt.detail.selectedItems[0])}}
    />
  );
}

function FileEventTableView() {
  const [columnDefinitions, saveWidths] = useColumnWidths('React-TableServerSide-Widths', COLUMN_DEFINITIONS);
  const [toolsOpen, setToolsOpen] = useState(false);

  return (
    <CustomAppLayout
      navigation={<Navigation activeHref="/FileEvents" />}
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

export default FileEventTableView;