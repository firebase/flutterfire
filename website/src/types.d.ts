/// <reference types="@docusaurus/module-type-aliases" />

declare module '*.scss' {
  const content: { [className: string]: string };
  export default content;
}
