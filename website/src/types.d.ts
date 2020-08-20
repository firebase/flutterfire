/// <reference types="@docusaurus/module-type-aliases" />

declare module '*.scss' {
  const content: { [className: string]: string };
  export default content;
}

declare module '*/docs/versions' {
  const versions: Versions;

  type Versions = {
    plugins: { [plugin: string]: string };
  };

  export default versions;
}

declare module '*.png' {
  const image: any;
  export default image;
}
