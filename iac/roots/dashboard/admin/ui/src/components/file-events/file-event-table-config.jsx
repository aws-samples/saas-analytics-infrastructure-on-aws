// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
import React from 'react';
import { CollectionPreferences} from '@cloudscape-design/components';
import { addColumnSortLabels } from '../../common/labels';

export const COLUMN_DEFINITIONS = addColumnSortLabels([
  {
    id: 'customer',
    sortingField: 'customer',
    header: 'Customer',
    cell: item => item.customer,
    minWidth: 75,
  },
  {
    id: 'date',
    sortingField: 'date',
    header: 'Date',
    cell: item => item.date,
    minWidth: 200,
  },
  {
    id: 'name',
    sortingField: 'name',
    header: 'Name',
    cell: item => item.name,
    minWidth: 300,
  },
  {
    id: 'dataset',
    sortingField: 'dataset',
    header: 'Dataset',
    cell: item => item.dataset,
    minWidth: 75,
  },
  {
    id: 'rows',
    sortingField: 'rows',
    header: 'Rows',
    cell: item => item.rows,
    minWidth: 75,
  },
  {
    id: 'columns',
    sortingField: 'columns',
    header: 'Columns',
    cell: item => item.columns,
    minWidth: 75,
  },
  {
    id: 'bytes',
    sortingField: 'bytes',
    header: 'Bytes',
    cell: item => item.bytes,
    minWidth: 75,
  }
]);

const VISIBLE_CONTENT_OPTIONS = [
  {
    label: 'Main file event properties',
    options: [
      { id: 'customer', label: 'Customer', editable: true },
      { id: 'date', label: 'Date', editable: true },
      { id: 'name', label: 'Name', editable: true },
      { id: 'dataset', label: 'Dataset', editable: true },
      { id: 'rows', label: 'Rows', editable: true },
      { id: 'columns', label: 'Columns', editable: true },
      { id: 'bytes', label: 'Bytes', editable: true }
    ],
  },
];

export const PAGE_SIZE_OPTIONS = [
  { value: 10, label: '10 File Events' },
  { value: 25, label: '25 File Events' },
  { value: 50, label: '50 File Events' },
];

export const DEFAULT_PREFERENCES = {
  pageSize: 10,
  visibleContent: ['customer', 'date', 'name', 'dataset', 'rows', 'columns', 'bytes' ],
  wrapLines: false,
};

export const FILTERING_PROPERTIES = [
  {
    propertyLabel: 'Customer',
    key: 'customer',
    groupValuesLabel: 'Customer values',
    operators: [':', '!:', '=', '!='],
  },
  {
    propertyLabel: 'Date',
    key: 'date',
    groupValuesLabel: 'Date values',
    operators: [':', '!:', '=', '!='],
  },
  {
    propertyLabel: 'Name',
    key: 'name',
    groupValuesLabel: 'Name values',
    operators: [':', '!:', '=', '!='],
  },
  {
    propertyLabel: 'Dataset',
    key: 'dataset',
    groupValuesLabel: 'Dataset values',
    operators: [':', '!:', '=', '!='],
  },
  {
    propertyLabel: 'Rows',
    key: 'rows',
    groupValuesLabel: 'Rows values',
    operators: [':', '!:', '=', '!='],
  },
  {
    propertyLabel: 'Columns',
    key: 'columns',
    groupValuesLabel: 'Columns values',
    operators: [':', '!:', '=', '!='],
  },
  {
    propertyLabel: 'Bytes',
    key: 'bytes',
    groupValuesLabel: 'Bytes values',
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
