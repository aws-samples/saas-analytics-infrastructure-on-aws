// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
import React from 'react';
import { CollectionPreferences} from '@cloudscape-design/components';
import { addColumnSortLabels } from '../../common/labels';

export const COLUMN_DEFINITIONS = addColumnSortLabels([
  {
    id: 'date',
    sortingField: 'date',
    header: 'Date',
    cell: item => item.date,
    minWidth: 100,
  },
  {
    id: 'time',
    sortingField: 'time',
    header: 'Time',
    cell: item => item.time,
    minWidth: 100,
  },
  {
    id: 'duration',
    sortingField: 'duration',
    header: 'Duration',
    cell: item => item.duration,
    minWidth: 100,
  },
  {
    id: 'files',
    sortingField: 'files',
    header: 'Files',
    cell: item => item.files,
    minWidth: 100,
  },
  {
    id: 'executor',
    sortingField: 'executor',
    header: 'Executor',
    cell: item => item.executor,
    minWidth: 100,
  }
]);

const VISIBLE_CONTENT_OPTIONS = [
  {
    label: 'Main file event properties',
    options: [
      { id: 'date', label: 'Date', editable: true },
      { id: 'time', label: 'Time', editable: true },
      { id: 'duration', label: 'Duration', editable: true },
      { id: 'files', label: 'Files', editable: true },
      { id: 'executor', label: 'Executor', editable: true }
    ]
  }
];

export const PAGE_SIZE_OPTIONS = [
  { value: 10, label: '10 Analytics Events' },
  { value: 25, label: '25 Analytics Events' },
  { value: 50, label: '50 Analytics Events' }
];

export const DEFAULT_PREFERENCES = {
  pageSize: 10,
  visibleContent: ['date', 'time', 'duration', 'files', 'executor'],
  wrapLines: false
};

export const FILTERING_PROPERTIES = [
  {
    propertyLabel: 'Date',
    key: 'date',
    groupValuesLabel: 'Date values',
    operators: [':', '!:', '=', '!='],
  },
  {
    propertyLabel: 'Time',
    key: 'time',
    groupValuesLabel: 'Time values',
    operators: [':', '!:', '=', '!='],
  },
  {
    propertyLabel: 'Duration',
    key: 'duration',
    groupValuesLabel: 'Duration values',
    operators: [':', '!:', '=', '!='],
  },
  {
    propertyLabel: 'Files',
    key: 'files',
    groupValuesLabel: 'Files values',
    operators: [':', '!:', '=', '!='],
  },
  {
    propertyLabel: 'Executor',
    key: 'executor',
    groupValuesLabel: 'Executor values',
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
