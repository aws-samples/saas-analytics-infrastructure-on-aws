// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

import { SideNavigation } from "@cloudscape-design/components";
import React from "react";
import { useHistory } from "react-router-dom";

export const navHeader = { text: '###APP_TITLE###', href: '/' };
export const navItems = [
  {
    type: 'section',
    text: 'Analytics Processing',
    items: [
      // { type: 'link', text: 'Analytics', href: '/Analytics' },
      // { type: 'link', text: 'Customers', href: '/Customers' },
      { type: 'link', text: 'Input Files', href: '/InputFiles' },
      { type: 'link', text: 'Output Files', href: '/OutputFiles' },
    ],
  }
];

const defaultOnFollowHandler = ev => {
  console.log("Text : " + ev.detail.text)

  // ev.preventDefault();
};

export function Navigation({
  activeHref,
  header = navHeader,
  items = navItems,
  onFollowHandler = defaultOnFollowHandler,
}) {

  const history = useHistory();

  const defaultOnFollowHandler = ev => {
    ev.preventDefault();
    history.push("/" + ev.detail.text.replace(" ", ""));
  };

  return <SideNavigation items={items} header={header} activeHref={activeHref} onFollow={defaultOnFollowHandler} />;
}