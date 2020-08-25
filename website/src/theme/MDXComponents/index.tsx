import React, { HTMLProps } from 'react';
import Link from '@docusaurus/Link';
import CodeBlock from '@theme/CodeBlock';
import Tabs from '@theme/Tabs';
import Heading from '@theme/Heading';
import TabItem from '@theme/TabItem';
import IdealImage from '@theme/IdealImage';
import Zoom from 'react-medium-image-zoom';

import styles from './styles.module.scss';
import 'react-medium-image-zoom/dist/styles.css';

import { getVersion } from '../../utils';

// @ts-ignore
const reference = REFERENCE_API;

export default {
  a: (props: HTMLProps<HTMLAnchorElement>) => {
    if (props.href && props.href.startsWith('!')) {
      const name = props.href.replace('!', '');
      const entity = reference[name];

      if (entity) {
        return (
          <a
            {...props}
            target="_blank"
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

  img: (props: HTMLProps<HTMLImageElement>) => {
    // @ts-ignore
    if (props['data-asset'] === 'false') {
      // @ts-ignore
      return <img {...props} />;
    }

    let alt = props.alt || '';

    // Prefix any alt tags with "hide:" to not show them as a caption
    if (alt.startsWith('hide:')) {
      alt = alt.replace('hide:', '');
    }

    // Windows Workaround
    if (!props.src) return null;
    if (props.src.startsWith('http')) {
      return (
        <figure className={styles.figure}>
          <Zoom>
            {/* @ts-ignore */}
            <img {...props} />
          </Zoom>
          {alt === props.alt && <figcaption>{alt}</figcaption>}
        </figure>
      );
    }

    let imgSrc;
    try {
      imgSrc = require(`../../../../docs/_assets/${props.src}`);
    } catch (e) {
      console.log(e);
      return null;
    }

    if (!imgSrc) return null;

    return (
      <figure className={styles.figure}>
        <Zoom>
          <IdealImage img={imgSrc} alt={alt} quality={100} />
        </Zoom>
        {alt === props.alt && <figcaption>{alt}</figcaption>}
      </figure>
    );
  },

  pre: (props: HTMLProps<HTMLDivElement>) => <div className={styles.mdxCodeBlock} {...props} />,

  inlineCode: (props: HTMLProps<HTMLElement>) => {
    const { children } = props;
    if (typeof children === 'string') {
      return <code {...props}>{getVersion(children)}</code>;
    }
    return children;
  },

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

  table: (props: HTMLProps<HTMLTableElement>) => (
    <div style={{ overflowX: 'auto' }}>
      <table {...props} />
    </div>
  ),

  Tabs,
  TabItem,

  blockquote: (props: HTMLProps<HTMLElement>) => (
    <blockquote className={styles.blockquote} {...props} />
  ),

  //Enables global usage of <YouTube id="xxxx" /> within MDX files
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
