import React, { useState } from 'react';
import Link from '@docusaurus/Link';
import useThemeContext from '@theme/hooks/useThemeContext';
import { usePluginData } from '@docusaurus/useGlobalData';

const serviceColor = {
  auth: '#2196f3',
  firestore: '#ff9800',
  database: '#4caf50',
};

function Card({ href, name, service, description }) {
  const { isDarkTheme } = useThemeContext();

  return (
    <Link
      to={`https://pub.dev/documentation/flutterfire_ui/latest/${href}`}
      style={{
        textDecoration: 'inherit',
        color: 'inherit',
        display: 'flex',
        height: '100%',
        flexDirection: 'column',
        backgroundColor: isDarkTheme ? '#0f0f10' : '#fff',
        borderRadius: '0.5rem',
        boxShadow:
          'rgba(0, 0, 0, 0.05) 0px 6px 24px 0px, rgba(0, 0, 0, 0.08) 0px 0px 0px 1px',
        overflow: 'hidden',
      }}
    >
      {/* <div
        style={{
          position: 'relative',
          height: 150,
          background: `url(${img}) no-repeat center center`,
          backgroundSize: 'contain',
        }}
      /> */}
      <div
        style={{
          flexGrow: 1,
          backgroundColor: isDarkTheme ? '#0f0f10' : '#fff',
          padding: '1rem',
          borderTop: '1px solid rgba(0, 0, 0, 0.08)',
        }}
      >
        <span
          style={{
            backgroundColor: serviceColor[service],
            fontSize: '.85rem',
            padding: '.2rem .6rem',
            borderRadius: '999px',
            color: '#fff',
          }}
        >
          {service}
        </span>
        <h3 style={{ marginTop: '.8rem' }}>{name}</h3>
        <p
          style={{
            margin: 0,
            fontSize: '.9rem',
          }}
        >
          {description}
        </p>
      </div>
    </Link>
  );
}

export function Widgets() {
  if (typeof window === 'undefined') {
    return null;
  }

  const data = usePluginData('@flutterfire/source-ui-widgets');
  const params = new URLSearchParams(window.location.search);
  const [query, setQuery] = useState(params.get('query') || '');
  const [service, setService] = useState(params.get('service') || 'all');

  const widgets = data
    .map((item) => {
      if (!item.subcategories) {
        return null;
      }

      let service;
      let type;
      let img;
      let description = '';

      item.subcategories.forEach((value) => {
        if (value.startsWith('service:'))
          service = value.replace('service:', '');
        if (value.startsWith('type:')) type = value.replace('type:', '');
        if (value.startsWith('img:')) img = value.replace('img:', '');
        if (value.startsWith('description:'))
          description = value.replace('description:', '');
      });

      if (!service || !type) return null;

      return {
        href: item.href,
        name: item.name,
        service,
        type,
        img,
        description,
      };
    })
    .filter(Boolean);

  function updateSearchParams() {
    const path =
      window.location.protocol +
      '//' +
      window.location.host +
      window.location.pathname +
      '?' +
      params.toString();
    window.history.pushState({ path }, '', path);
  }

  let filtered = widgets;

  if (query) {
    filtered = filtered.filter((widget) => {
      return (
        widget.name.toLowerCase().includes(query.toLowerCase()) ||
        widget.description.toLowerCase().includes(query.toLowerCase())
      );
    });
  }

  if (service !== 'all') {
    filtered = filtered.filter((widget) => widget.service === service);
  }

  return (
    <section>
      <div
        style={{
          marginBottom: '1rem',
          display: 'flex',
          gap: '1rem',
          alignItems: 'center',
        }}
      >
        <input
          name="search"
          value={query}
          placeholder="Search widgets..."
          onChange={(e) => {
            const query = e.target.value;
            setQuery(query);
            params.set('query', query);
            updateSearchParams();
          }}
          style={{
            width: 300,
            padding: '.4rem .6rem',
          }}
        />
        <select
          name="service"
          style={{ width: 150, padding: '.4rem .6rem' }}
          value={service}
          onChange={(e) => {
            const service = e.target.value;
            setService(service);
            params.set('service', service);
            updateSearchParams();
          }}
        >
          <option value="all">All Services</option>
          <option value="auth">Auth</option>
          <option value="firestore">Firestore</option>
        </select>
      </div>
      <div className="grid grid-3">
        {filtered.map((widget) => (
          <div key={widget.name}>
            <Card {...widget} />
          </div>
        ))}
      </div>
    </section>
  );
}
