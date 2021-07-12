import React from 'react';
import { Redirect } from 'react-router-dom';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';

function DocsRedirect(): JSX.Element {
  const context = useDocusaurusContext();
  const { siteConfig } = context;

  return <Redirect to={`${siteConfig.baseUrl}docs/overview`} />;
}

export default DocsRedirect;
