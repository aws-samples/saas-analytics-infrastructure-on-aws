// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
import React from 'react';
import { CollectionPreferences} from '@cloudscape-design/components';
import { addColumnSortLabels } from '../../common/labels';

export const COLUMN_DEFINITIONS = addColumnSortLabels([
  {
    id: 'name',
    sortingField: 'name',
    header: 'Name',
    cell: item => item.name,
    minWidth: 400,
  },
  {
    id: 'type',
    sortingField: 'type',
    header: 'Type',
    cell: item => item.type,
    minWidth: 100,
  },
  {
    id: 'date',
    sortingField: 'date',
    header: 'Date',
    cell: item => item.date,
    minWidth: 150,
  },
  {
    id: 'customer',
    sortingField: 'customer',
    header: 'Customer',
    cell: item => item.customer,
    minWidth: 150,
  },
  {
    id: 'dataset',
    sortingField: 'dataset',
    header: 'Dataset',
    cell: item => item.dataset,
    minWidth: 400,
  }
]);

const VISIBLE_CONTENT_OPTIONS = [
  {
    label: 'Main customer input file properties',
    options: [
      { id: 'name', label: 'Name', editable: false },
      { id: 'type', label: 'Type', editable: true },
      { id: 'date', label: 'Date', editable: true },
      { id: 'customer', label: 'Customer', editable: true },
      { id: 'dataset', label: 'Dataset', editable: true }
    ],
  },
];

export const PAGE_SIZE_OPTIONS = [
  { value: 10, label: '10 Files' },
  { value: 25, label: '25 Files' },
  { value: 50, label: '50 Files' },
];

export const DEFAULT_PREFERENCES = {
  pageSize: 10,
  visibleContent: ['name', 'type', 'date', 'customer', 'dataset'],
  wrapLines: false,
};

export const FILTERING_PROPERTIES = [
  {
    propertyLabel: 'Name',
    key: 'name',
    groupValuesLabel: 'Name values',
    operators: [':', '!:', '=', '!='],
  },
  {
    propertyLabel: 'Type',
    key: 'type',
    groupValuesLabel: 'Type values',
    operators: [':', '!:', '=', '!='],
  },
  {
    propertyLabel: 'Date',
    key: 'date',
    groupValuesLabel: 'Date values',
    operators: [':', '!:', '=', '!='],
  },
  {
    propertyLabel: 'Customer',
    key: 'customer',
    groupValuesLabel: 'Customer values',
    operators: [':', '!:', '=', '!='],
  },
  {
    propertyLabel: 'dataset',
    key: 'dataset',
    groupValuesLabel: 'Dataset values',
    operators: [':', '!:', '=', '!='],
  }

];

export const PROPERTY_FILTERING_I18N_CONSTANTS = {
  filteringAriaLabel: 'your choice',
  dismissAriaLabel: 'Dismiss',

  filteringPlaceholder: 'Search',
  groupValuesText: 'Values',
  groupPropertiesText: 'Properties',
  operatorsText: 'Operators',

  operationAndText: 'and',
  operationOrText: 'or',

  operatorLessText: 'Less than',
  operatorLessOrEqualText: 'Less than or equal',
  operatorGreaterText: 'Greater than',
  operatorGreaterOrEqualText: 'Greater than or equal',
  operatorContainsText: 'Contains',
  operatorDoesNotContainText: 'Does not contain',
  operatorEqualsText: 'Equals',
  operatorDoesNotEqualText: 'Does not equal',

  editTokenHeader: 'Edit filter',
  propertyText: 'Property',
  operatorText: 'Operator',
  valueText: 'Value',
  cancelActionText: 'Cancel',
  applyActionText: 'Apply',
  allPropertiesLabel: 'All properties',

  tokenLimitShowMore: 'Show more',
  tokenLimitShowFewer: 'Show fewer',
  clearFiltersText: 'Clear filters',
  removeTokenButtonAriaLabel: () => 'Remove token',
  enteredTextLabel: text => `Use: "${text}"`,
};

export const Preferences = ({
                              preferences,
                              setPreferences,
                              disabled,
                              pageSizeOptions = PAGE_SIZE_OPTIONS,
                              visibleContentOptions = VISIBLE_CONTENT_OPTIONS,
                            }) => (
    <CollectionPreferences
        title="Preferences"
        confirmLabel="Confirm"
        cancelLabel="Cancel"
        disabled={disabled}
        preferences={preferences}
        onConfirm={({ detail }) => setPreferences(detail)}
        pageSizePreference={{
          title: 'Page size',
          options: pageSizeOptions,
        }}
        wrapLinesPreference={{
          label: 'Wrap lines',
          description: 'Check to see all the text and wrap the lines',
        }}
        visibleContentPreference={{
          title: 'Select visible columns',
          options: visibleContentOptions,
        }}
    />
);
