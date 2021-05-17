import React, { CSSProperties } from 'react';

type Props = {
  zIndex?: number;
  light: string;
  dark: string;
  style?: CSSProperties;
  rotate?: number;
};

function Triangle({ zIndex = 0, light, dark, style = {}, rotate = 0 }: Props): JSX.Element {
  return (
    <svg
      width={500}
      height={500}
      xmlns="http://www.w3.org/2000/svg"
      className={`text-${light} dark-text-${dark}`}
      style={{
        position: 'absolute',
        zIndex,
        transform: `rotate(${rotate}deg)`,
        ...style,
      }}
    >
      <path
        fill="currentColor"
        d="
          M 0,0
          L 0,500
          L 500,0
          z
        "
      />
    </svg>
  );
}

export { Triangle };
