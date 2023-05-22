// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
import React from 'react';
import { CollectionPreferences} from '@cloudscape-design/components';
import { addColumnSortLabels } from '../../common/labels';

export const COLUMN_DEFINITIONS = addColumnSortLabels([
  {
    id: 'id',
    sortingField: 'id',
    header: 'ID',
    cell: item => item.id,
    minWidth: 200,
  }
]);

const VISIBLE_CONTENT_OPTIONS = [
  {
    label: 'Main customer properties',
    options: [
      { id: 'id', label: 'ID', editable: true }
    ]
  }
];

export const PAGE_SIZE_OPTIONS = [
  { value: 10, label: '10 Customers' },
  { value: 25, label: '25 Customers' },
  { value: 50, label: '50 Customers' }
];

export const DEFAULT_PREFERENCES = {
  pageSize: 10,
  visibleContent: ['id'],
  wrapLines: false
};

export const FILTERING_PROPERTIES = [
  {
    propertyLabel: 'ID',
    key: 'id',
    groupValuesLabel: 'ID values',
    operators: [':', '!:', '=', '!=']
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
