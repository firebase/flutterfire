import React, { HTMLProps } from 'react';
import Link from '@docusaurus/Link';
import CodeBlock from '@theme/CodeBlock';
import Heading from '@theme/Heading';
import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

import styles from './styles.module.scss';
import { getVersion } from '../../utils';

export default {
  a: (props: HTMLProps<HTMLAnchorElement>) => {
    if (/\.[^./]+$/.test(props.href || '')) {
      return <a {...props} />;
    }
    return <Link {...props} />;
  },

  pre: (props: HTMLProps<HTMLDivElement>) => <div className={styles.mdxCodeBlock} {...props} />,
  code: (props: HTMLProps<HTMLElement>) => {
    const { children } = props;
    if (typeof children === 'string') {
      return <CodeBlock {...props}>{getVersion(children)}</CodeBlock>;
    }
    return children;
  },

  h1: Heading('h1'),
  h2: Heading('h2'),
  h3: Heading('h3'),
  h4: Heading('h4'),
  h5: Heading('h5'),
  h6: Heading('h6'),

  Tabs,
  TabItem,

  blockquote: (props: HTMLProps<HTMLElement>) => (
    <blockquote className={styles.blockquote} {...props} />
  ),

  // Enables global usage of <YouTube id="xxxx" /> within MDX files
  YouTube: ({ id }: { id: string }) => {
    return (
      <div className={styles.youtube}>
        <iframe
          frameBorder="0"
          src={`https://www.youtube.com/embed/${id}`}
          allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture"
          allowFullScreen
        />
      </div>
    );
  },
};
