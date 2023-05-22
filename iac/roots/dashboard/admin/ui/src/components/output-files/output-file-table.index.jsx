// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
import React, { useEffect, useState } from 'react';
import PropertyFilter from "@cloudscape-design/components/property-filter";
import { useCollection } from '@cloudscape-design/collection-hooks';
import { COLUMN_DEFINITIONS, FILTERING_PROPERTIES, PROPERTY_FILTERING_I18N_CONSTANTS, DEFAULT_PREFERENCES, Preferences } from './output-file-table-config';
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
import { ICustomerFile, ReduxRoot } from "../../interfaces";

import { useDispatch, useSelector } from "react-redux";
import { storeCustomerFile } from "../../redux/actions";
import { useHistory } from "react-router-dom";
import { getOutputFiles } from "../../data";

export const resourcesBreadcrumbs = [
  {
    text: 'Output Files',
    href: '/OutputFiles'
  },
];

export const Breadcrumbs = () => (
    <BreadcrumbGroup items={resourcesBreadcrumbs} expandAriaLabel="Show path" ariaLabel="Breadcrumbs" />
);

export const FullPageHeader = ({
                                 resourceName = 'Output File',
                                 createButtonText = 'Create output file',
                                 ...props
                               }) => {
  const isOnlyOneSelected = props.selectedItems.length === 1;

  const history = useHistory();

  const onOpenClick = () => {
    history.push("/OutputFile");
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
        header={<h2>Output Files</h2>}
        footer={
          <>
          </>
        }
    >
      <p>
        View all the output files.
      </p>
    </HelpPanel>
);

function TableContent({updateTools }) {

  const dispatch = useDispatch();

  const token = useSelector( (state:ReduxRoot) => {
    return state.reducerState.token
  });

  const [files, setFiles] = useState([]);
  const [selectedFiles, setSelectedFiles] = useState([]);

  const [columnDefinitions, saveWidths] = useColumnWidths('React-Table-Widths', COLUMN_DEFINITIONS);
  const [preferences, setPreferences] = useLocalStorage('React-DistributionsTable-Preferences', DEFAULT_PREFERENCES);

  const { items, actions, filteredItemsCount, collectionProps, paginationProps, propertyFilterProps } = useCollection(
      files,
    {
      propertyFiltering: {
        filteringProperties: FILTERING_PROPERTIES,
        empty: <TableEmptyState resourceName="Output Files" />,
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

  const getAllOutputFiles = async () => {

    try {

      await getOutputFiles(token).then(
          (result: ICustomerFile[]) => {
            setFiles(result);
          });

      await Promise.resolve();

    }
    catch (err) {
      console.log("Got Error Message: " + err.toString());
    }
  }

  useEffect( () => {

    getAllOutputFiles().then(() => console.log("getAllOutputFiles() completed."));
  }, []);

  const selectFile = (customerFile: ICustomerFile) => {
    dispatch(storeCustomerFile(customerFile?customerFile: {}));
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
          selectedItems={selectedFiles}
          totalItems={files}
          updateTools={updateTools}
          serverSide={false}
        />
      }
      loadingText="Loading output files"
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
      selectedItems={selectedFiles}
      onSelectionChange={evt => {setSelectedFiles(evt.detail.selectedItems); selectFile(evt.detail.selectedItems[0])}}
    />
  );
}

function OutputFileTableView() {
  const [columnDefinitions, saveWidths] = useColumnWidths('React-TableServerSide-Widths', COLUMN_DEFINITIONS);
  const [toolsOpen, setToolsOpen] = useState(false);

  return (
    <CustomAppLayout
      navigation={<Navigation activeHref="/OutputFiles" />}
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

export default OutputFileTableView;