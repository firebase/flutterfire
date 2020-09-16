import get from 'lodash.get';
import versions from '../../docs/versions';

const regex = /{{\s([a-zA-Z0-9_.]*)\s}}/gm;

export function getVersion(value: string) {
  let output = value;
  let m;

  while ((m = regex.exec(value)) !== null) {
    // This is necessary to avoid infinite loops with zero-width matches
    if (m.index === regex.lastIndex) {
      regex.lastIndex++;
    }

    output = output.replace(m[0], get(versions, m[1], ''));
  }
  return output;
}
