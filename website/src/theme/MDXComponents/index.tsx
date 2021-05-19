import React, { HTMLProps } from 'react';
import Link from '@docusaurus/Link';
import CodeBlock from '@theme/CodeBlock';
import Tabs from '@theme/Tabs';
import Heading from '@theme/Heading';
import TabItem from '@theme/TabItem';
import Zoom from 'react-medium-image-zoom';

import styles from './styles.module.scss';
import 'react-medium-image-zoom/dist/styles.css';

import { getVersion } from '../../utils';

// @ts-ignore
const reference = REFERENCE_API;

export default {
  a: (props: HTMLProps<HTMLAnchorElement>): JSX.Element => {
    if (props.href && props.href.startsWith('!')) {
      const name = props.href.replace('!', '');
      const entity = reference[name];

      if (entity) {
        return (
          <a
            {...props}
            target="_blank"
            rel="noreferrer"
            href={`https://pub.dev/documentation/${entity.plugin}/${entity.version}/${entity.href}`}
          />
        );
      } else {
        return <span>{props.children}</span>;
      }
    }

    if (/\.[^./]+$/.test(props.href || '')) {
      return <a {...props} />;
    }
    return <Link {...props} />;
  },

  pre: (props: HTMLProps<HTMLDivElement>): JSX.Element => (
    <div className={styles.mdxCodeBlock} {...props} />
  ),

  inlineCode: (props: HTMLProps<HTMLElement>): JSX.Element => {
    const { children } = props;
    if (typeof children === 'string') {
      return <code {...props}>{getVersion(children)}</code>;
    }
    return children as JSX.Element;
  },

  code: (props: HTMLProps<HTMLElement>): JSX.Element => {
    const { children } = props;
    if (typeof children === 'string') {
      return <CodeBlock {...props}>{getVersion(children)}</CodeBlock>;
    }
    return children as JSX.Element;
  },

  h1: Heading('h1'),
  h2: Heading('h2'),
  h3: Heading('h3'),
  h4: Heading('h4'),
  h5: Heading('h5'),
  h6: Heading('h6'),

  table: (props: HTMLProps<HTMLTableElement>): JSX.Element => (
    <div style={{ overflowX: 'auto' }}>
      <table {...props} />
    </div>
  ),

  Tabs,
  TabItem,

  blockquote: (props: HTMLProps<HTMLElement>): JSX.Element => (
    <blockquote className={styles.blockquote} {...props} />
  ),

  //Enables global usage of <YouTube id="xxxx" /> within MDX files
  YouTube: ({ id }: { id: string }): JSX.Element => {
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

  Image: ({
    src,
    alt,
    caption = true,
    zoom = true,
  }: {
    src: string;
    alt?: string;
    zoom?: boolean;
    caption?: boolean;
  }): JSX.Element => {
    let image;
    const isExternalImage = src.startsWith('http');

    if (!isExternalImage) {
      try {
        image = require(`../../../../docs/_assets/${src}`).default;
      } catch (e) {
        console.error(e);
        image = '';
      }
    } else {
      image = src;
    }

    const withZoom = (children: React.ReactNode) => <Zoom>{children}</Zoom>;

    return (
      <figure className={styles.figure}>
        {zoom && withZoom(<img src={image} alt={alt || 'No alt text.'} />)}
        {!zoom && <img src={image} alt={alt || 'No alt text.'} />}
        {!!alt && caption && <figcaption>{alt}</figcaption>}
      </figure>
    );
  },
};
