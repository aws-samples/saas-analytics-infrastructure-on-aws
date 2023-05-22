// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

import React, { useState } from 'react';
import { AppLayout, BreadcrumbGroup, ContentLayout, HelpPanel } from '@cloudscape-design/components';
import { Button, Form, Header, SpaceBetween } from '@cloudscape-design/components';
import { Navigation } from '../common/navigation';
import { Notifications } from '../common/notifications';
import { appLayoutLabels } from '../../common/labels';
import '../../styles/form.scss';
import { InfoLink } from "../common/links";
import Container from "@cloudscape-design/components/container";
import FormField from "@cloudscape-design/components/form-field";
import { useSelector } from "react-redux";
import { ReduxRoot } from "../../interfaces";
import { useHistory } from "react-router-dom";
import { putFileContent } from "../../data";

export const resourcesBreadcrumbs = [
  {
    text: 'Input Files',
    href: '/InputFiles',
  },
  {
    text: 'Input File Form',
    href: '/InputFileForm',
  }
];

export const Breadcrumbs = () => (
    <BreadcrumbGroup items={resourcesBreadcrumbs} expandAriaLabel="Show path" ariaLabel="Breadcrumbs" />
);

export const ToolsContent = () => (
    <HelpPanel
        header={<h2>Input File Form</h2>}
        footer={
          <>
          </>
        }
    >
      <p>
        Add an input files.
      </p>
    </HelpPanel>
);

export function FormHeader({ }) {
  return (
      <Header
          variant="h1"
          info={
            <InfoLink
                id="form-main-info-link"
                ariaLabel={'Add an input file.'}
            />
          }
          description="Add an input file."
      >
        Add an input file
      </Header>
  );
}

export function FormContent({ }) {

  const token = useSelector( (state:ReduxRoot) => {
    return state.reducerState.token
  });

  const [selectedFile, setSelectedFile] = useState({});

  const history = useHistory();

  const onUpload = async () => {

    try {

      console.log("SELECTED FILE =" + selectedFile + "=")
      console.log("SELECTED FILE NAME =" + selectedFile.name + "=")
      if (selectedFile !== {}) {
        const formData = new FormData();
        formData.append('File', selectedFile);

        console.log("Form Data : " + JSON.stringify(formData))
        await putFileContent(token, formData);
        await Promise.resolve();

        history.push("/InputFiles");
      }
    }
    catch (err) {
      console.log("Got Error Message: " + err.toString());
    }
  }

  const onCancel = async () => {

    history.push("/InputFiles");
  }

  const onFileSelection = (event) => {
    // console.log("Event Type : " + event.type)
    // console.log("Event KEYS")
    // Object.keys(event).forEach(key => console.log(key));
    // console.log("Target KEYS")
    // Object.keys(event.target).forEach(key => console.log(key));
    // console.log("Target Value : " + event.target.value)
    // console.log("Current Target KEYS")
    // Object.keys(event.currentTarget).forEach(key => console.log(key));
    // console.log("Target Value : " + event.currentTarget.value)
    // console.log("CURRENT TARGET File :" + event.target.value)
    // console.log("File Selected: " + JSON.stringify(event.target.value))
    // console.log("File Details:")
    // console.log("TARGET FILE LENGTH : " + event.target.files.length);
    // console.log("TARGET FILE 1 : " + event.target.files[0]);
    // console.log("TARGET FILE 1 Name : " + event.target.files[0].name);
    // console.log("TARGET FILE KEYS : ")
    // Object.keys(event.target.files[0]).forEach(key => console.log(key));
    setSelectedFile(event.target.files[0]);
  };

  return (
      <form onSubmit={event => event.preventDefault()}>
        <Form
            actions={
              <SpaceBetween direction="horizontal" size="xs">
                <Button variant="link" onClick={onCancel}>Cancel</Button>
                <Button onClick={onUpload} variant="primary">Upload</Button>
              </SpaceBetween>
            }
            errorText={""}
            errorIconAriaLabel="Error"
        >
          <SpaceBetween size="l">
            <Container
                id="origin-panel"
                className="custom-screenshot-hide"
                header={<Header variant="h2">Input File</Header>}
            >

              <SpaceBetween size="l">

                <FormField
                    label="Input File"
                >
                  <input
                      type="file"
                      onChange={onFileSelection}
                  />
                </FormField>

              </SpaceBetween>
            </Container>
          </SpaceBetween>
        </Form>
      </form>
  );
}

function InputFileForm() {
  const [toolsOpen, setToolsOpen] = useState(false);

  return (
      <AppLayout
          contentType="form"
          content={
            <ContentLayout header={<FormHeader />}>
              <FormContent />
            </ContentLayout>
          }
          headerSelector="#header"
          breadcrumbs={<Breadcrumbs />}
          navigation={<Navigation activeHref="/InputFiles" />}
          tools={<ToolsContent />}
          toolsOpen={toolsOpen}
          onToolsChange={({ detail}) => setToolsOpen(detail.open)}
          ariaLabels={appLayoutLabels}
          notifications={<Notifications />}
      />
  );
}

export default InputFileForm;