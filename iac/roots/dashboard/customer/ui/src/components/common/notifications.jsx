// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

import {useNotifications} from "./use-notifications";
import {Flashbar} from "@cloudscape-design/components";
import React from "react";

export function Notifications({ successNotification }) {
  const notifications = useNotifications(successNotification);
  return <Flashbar items={notifications} />;
}