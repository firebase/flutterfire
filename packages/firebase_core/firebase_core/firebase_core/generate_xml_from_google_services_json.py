#!/usr/bin/python

# Copyright 2016 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Stand-alone implementation of the Gradle Firebase plugin.

Converts the services json file to xml:
https://googleplex-android.googlesource.com/platform/tools/base/+/studio-master-dev/build-system/google-services/src/main/groovy/com/google/gms/googleservices
"""

__author__ = 'Wouter van Oortmerssen'

import argparse
import ctypes
import json
import os
import platform
import sys
from xml.etree import ElementTree

if platform.system().lower() == 'windows':
  import ctypes.wintypes  # pylint: disable=g-import-not-at-top

# Map Python 2's unicode method to encode a string as bytes in python 3.
try:
  unicode('')  # See whether unicode class is available (Python < 3)
except NameError:
  unicode = str  # pylint: disable=redefined-builtin,invalid-name

# Input filename if it isn't set.
DEFAULT_INPUT_FILENAME = 'app/google-services.json'
# Output filename if it isn't set.
DEFAULT_OUTPUT_FILENAME = 'res/values/googleservices.xml'
# Input filename for .plist files, if it isn't set.
DEFAULT_PLIST_INPUT_FILENAME = 'GoogleService-Info.plist'
# Output filename for .json files, if it isn't set.
DEFAULT_JSON_OUTPUT_FILENAME = 'google-services-desktop.json'

OAUTH_CLIENT_TYPE_ANDROID_APP = 1
OAUTH_CLIENT_TYPE_WEB = 3


def read_xml_value(xml_node):
  """Utility method for reading values from the plist XML.

  Args:
    xml_node: An ElementTree node, that contains a value.

  Returns:
    The value of the node, or None, if it could not be read.
  """
  if xml_node.tag == 'string':
    return xml_node.text
  elif xml_node.tag == 'integer':
    return int(xml_node.text)
  elif xml_node.tag == 'real':
    return float(xml_node.text)
  elif xml_node.tag == 'false':
    return 0
  elif xml_node.tag == 'true':
    return 1
  else:
    # other types of input are ignored.  (data, dates, arrays, etc.)
    return None


def construct_plist_dictionary(xml_root):
  """Constructs a dictionary of values based on the contents of a plist file.

  Args:
    xml_root: An ElementTree node, that represents the root of the xml file
              that is to be parsed.  (Which should be a dictionary containing
              key-value pairs of the properties that need to be extracted.)

  Returns:
    A dictionary, containing key-value pairs for all (supported) entries in the
    node.
  """
  xml_dict = xml_root.find('dict')

  if xml_dict is None:
    return None

  plist_dict = {}
  i = 0
  while i < len(xml_dict):
    if xml_dict[i].tag == 'key':
      key = xml_dict[i].text
      i += 1
      if i < len(xml_dict):
        value = read_xml_value(xml_dict[i])
        if value is not None:
          plist_dict[key] = value
    i += 1

  return plist_dict


def update_dict_keys(key_map, input_dict):
  """Creates a dict from input_dict with the same values but new keys.

  Two dictionaries are passed to this function: the key_map that represents a
  mapping of source keys to destination keys, and the input_dict that is the
  dictionary that is to be duplicated, replacing any key that matches a source
  key with a destination key. Source keys that are not present in the
  input_dict will not have their destination key represented in the result.

  In other words, if key_map is `{'old': 'new', 'foo': 'bar'}`, and input_dict
  is `{'old': 10}`, the result will be `{'new': 10}`.

  Args:
    key_map (dict): A dictionary of strings to strings that maps source keys to
      destination keys.
    input_dict (dict): The dictionary of string keys to any value type, which
      is to be duplicated, replacing source keys with the corresponding
      destination keys from key_map.

  Returns:
    dict: A new dictionary with updated keys.
  """
  return {
      new_key: input_dict[old_key]
      for (old_key, new_key) in key_map.items()
      if old_key in input_dict
  }


def construct_google_services_json(xml_dict):
  """Constructs a google services json file from a dictionary.

  Args:
    xml_dict: A dictionary of all the key/value pairs that are needed for the
              output json file.
  Returns:
    A string representing the output json file.
  """

  try:
    json_struct = {
        'project_info':
            update_dict_keys(
                {
                    'GCM_SENDER_ID': 'project_number',
                    'DATABASE_URL': 'firebase_url',
                    'PROJECT_ID': 'project_id',
                    'STORAGE_BUCKET': 'storage_bucket'
                }, xml_dict),
        'client': [{
            'client_info': {
                'mobilesdk_app_id': xml_dict['GOOGLE_APP_ID'],
                'android_client_info': {
                    'package_name': xml_dict['BUNDLE_ID']
                }
            },
            'oauth_client': [{
                'client_id': xml_dict['CLIENT_ID'],
            }],
            'api_key': [{
                'current_key': xml_dict['API_KEY']
            }],
            'services': {
                'analytics_service': {
                    'status': xml_dict['IS_ANALYTICS_ENABLED']
                },
                'appinvite_service': {
                    'status': xml_dict['IS_APPINVITE_ENABLED']
                }
            }
        },],
        'configuration_version':
            '1'
    }
    return json.dumps(json_struct, indent=2)
  except KeyError as e:
    sys.stderr.write('Could not find key in plist file: [%s]\n' % (e.args[0]))
    return None


def convert_plist_to_json(plist_string, input_filename):
  """Converts an input plist string into a .json file and saves it.

  Args:
    plist_string:    The contents of the loaded plist file.

    input_filename:  The file name that the plist data was read from.
  Returns:
    the converted string, or None if there were errors.
  """

  try:
    root = ElementTree.fromstring(plist_string)
  except ElementTree.ParseError:
    sys.stderr.write('Error parsing file %s.\n'
                     'It does not appear to be valid XML.\n' % (input_filename))
    return None

  plist_dict = construct_plist_dictionary(root)
  if plist_dict is None:
    sys.stderr.write('In file %s, could not locate a top-level \'dict\' '
                     'element.\n'
                     'File format should be plist XML, with a top-level '
                     'dictionary containing project settings as key-value '
                     'pairs.\n' % (input_filename))
    return None

  json_string = construct_google_services_json(plist_dict)
  return json_string


def gen_string(parent, name, text):
  """Generate one <string /> element and put into the list of keeps.

  Args:
    parent:  The object that will hold the string.
    name:    The name to store the string under.
    text:    The text of the string.
  """
  if text:
    prev = parent.get('tools:keep', '')
    if prev:
      prev += ','
    parent.set('tools:keep', prev + '@string/' + name)
    child = ElementTree.SubElement(parent, 'string', {
        'name': name,
        'translatable': 'false'
    })
    child.text = text


def indent(elem, level=0):
  """Recurse through XML tree and add indentation.

  Args:
    elem:  The element to recurse over
    level: The current indentation level.
  """
  i = '\n' + level*'  '
  if elem is not None:
    if not elem.text or not elem.text.strip():
      elem.text = i + '  '
    if not elem.tail or not elem.tail.strip():
      elem.tail = i
    for elem in elem:
      indent(elem, level+1)
    if not elem.tail or not elem.tail.strip():
      elem.tail = i
  else:
    if level and (not elem.tail or not elem.tail.strip()):
      elem.tail = i


def argv_as_unicode_win32():
  """Returns unicode command line arguments on windows.
  """

  get_command_line_w = ctypes.cdll.kernel32.GetCommandLineW
  get_command_line_w.restype = ctypes.wintypes.LPCWSTR

  # CommandLineToArgvW parses the Unicode command line
  command_line_to_argv_w = ctypes.windll.shell32.CommandLineToArgvW
  command_line_to_argv_w.argtypes = [
      ctypes.wintypes.LPCWSTR,
      ctypes.POINTER(ctypes.c_int)
  ]
  command_line_to_argv_w.restype = ctypes.POINTER(
      ctypes.wintypes.LPWSTR)

  argc = ctypes.c_int(0)
  argv = command_line_to_argv_w(get_command_line_w(), argc)

  # Strip the python executable from the arguments if it exists
  # (It would be listed as the first argument on the windows command line, but
  # not in the arguments to the python script)
  sys_argv_len = len(sys.argv)
  return [unicode(argv[i]) for i in
          range(argc.value - sys_argv_len, argc.value)]


def main():
  parser = argparse.ArgumentParser(
      description=((
          'Converts a Firebase %s into %s similar to the Gradle plugin, or '
          'converts a Firebase %s into a %s suitible for use on desktop apps.' %
          (DEFAULT_INPUT_FILENAME, DEFAULT_OUTPUT_FILENAME,
           DEFAULT_PLIST_INPUT_FILENAME, DEFAULT_JSON_OUTPUT_FILENAME))))
  parser.add_argument('-i', help='Override input file name',
                      metavar='FILE', required=False)
  parser.add_argument('-o', help='Override destination file name',
                      metavar='FILE', required=False)
  parser.add_argument('-p', help=('Package ID to select within the set of '
                                  'packages in the input file.  If this is '
                                  'not specified, the first package in the '
                                  'input file is selected.'))
  parser.add_argument('-l', help=('List all package IDs referenced by the '
                                  'input file.  If this is specified, '
                                  'the output file is not created.'),
                      action='store_true', default=False, required=False)
  parser.add_argument('-f', help=('Print project fields from the input file '
                                  'in the form \'name=value\\n\' for each '
                                  'field.  If this is specified, the output '
                                  'is not created.'),
                      action='store_true', default=False, required=False)
  parser.add_argument(
      '--plist',
      help=(
          'Specifies a plist file to convert to a JSON configuration file. '
          'If this is enabled, the script will expect a .plist file as input, '
          'which it will convert into %s file.  The output file is '
          '*not* suitable for use with Firebase on Android.' %
          (DEFAULT_JSON_OUTPUT_FILENAME)),
      action='store_true',
      default=False,
      required=False)

  # python 2 on Windows doesn't handle unicode arguments well, so we need to
  # pre-process the command line arguments before trying to parse them.
  if platform.system() == 'Windows':
    sys.argv = argv_as_unicode_win32()

  args = parser.parse_args()

  if args.plist:
    input_filename = DEFAULT_PLIST_INPUT_FILENAME
    output_filename = DEFAULT_JSON_OUTPUT_FILENAME
  else:
    input_filename = DEFAULT_INPUT_FILENAME
    output_filename = DEFAULT_OUTPUT_FILENAME

  if args.i:
    # Encode the input string (type unicode) as a normal string (type str)
    # using the 'utf-8' encoding so that it can be worked with the same as
    # input names from other sources (like the defaults).
    input_filename_raw = args.i.encode('utf-8')
    # Decode the filename to a unicode string using the 'utf-8' encoding to
    # properly handle filepaths with unicode characters in them.
    input_filename = input_filename_raw.decode('utf-8')

  if args.o:
    output_filename = args.o

  with open(input_filename, 'r') as ifile:
    file_string = ifile.read()

  json_string = None
  if args.plist:
    json_string = convert_plist_to_json(file_string, input_filename)
    if json_string is None:
      return 1
    jsobj = json.loads(json_string)
  else:
    jsobj = json.loads(file_string)

  root = ElementTree.Element('resources')
  root.set('xmlns:tools', 'http://schemas.android.com/tools')

  project_info = jsobj.get('project_info')
  if project_info:
    gen_string(root, 'firebase_database_url', project_info.get('firebase_url'))
    gen_string(root, 'gcm_defaultSenderId', project_info.get('project_number'))
    gen_string(root, 'google_storage_bucket',
               project_info.get('storage_bucket'))
    gen_string(root, 'project_id', project_info.get('project_id'))

  if args.f:
    if not project_info:
      sys.stderr.write('No project info found in %s.' % input_filename)
      return 1
    for field, value in sorted(project_info.items()):
      sys.stdout.write('%s=%s\n' % (field, value))
    return 0

  packages = set()
  client_list = jsobj.get('client')
  if client_list:
    # Search for the user specified package in the file.
    selected_package_name = ''
    selected_client = client_list[0]
    find_package_name = args.p
    for client in client_list:
      package_name = client.get('client_info', {}).get(
          'android_client_info', {}).get('package_name', '')
      if not package_name:
        package_name = client.get('oauth_client', {}).get(
            'android_info', {}).get('package_name', '')
      if package_name:
        if not selected_package_name:
          selected_package_name = package_name
          selected_client = client
        if package_name == find_package_name:
          selected_package_name = package_name
          selected_client = client
        packages.add(package_name)

    if args.p and selected_package_name != find_package_name:
      sys.stderr.write('No packages found in %s which match the package '
                       'name %s\n'
                       '\n'
                       'Found the following:\n'
                       '%s\n' % (input_filename, find_package_name,
                                 '\n'.join(packages)))
      return 1

    client_api_key = selected_client.get('api_key')
    if client_api_key:
      client_api_key0 = client_api_key[0]
      gen_string(root, 'google_api_key', client_api_key0.get('current_key'))
      gen_string(root, 'google_crash_reporting_api_key',
                 client_api_key0.get('current_key'))

    client_info = selected_client.get('client_info')
    if client_info:
      gen_string(root, 'google_app_id', client_info.get('mobilesdk_app_id'))

    # Only include the first matching OAuth client ID per type.
    client_id_web_parsed = False
    client_id_android_parsed = False

    oauth_client_list = selected_client.get('oauth_client')
    if oauth_client_list:
      for oauth_client in oauth_client_list:
        client_type = oauth_client.get('client_type')
        client_id = oauth_client.get('client_id')
        if not (client_type and client_id): continue
        if (client_type == OAUTH_CLIENT_TYPE_WEB and
            not client_id_web_parsed):
          gen_string(root, 'default_web_client_id', client_id)
          client_id_web_parsed = True
        if (client_type == OAUTH_CLIENT_TYPE_ANDROID_APP and
            not client_id_android_parsed):
          gen_string(root, 'default_android_client_id', client_id)
          client_id_android_parsed = True

    services = selected_client.get('services')
    if services:
      ads_service = services.get('ads_service')
      if ads_service:
        gen_string(root, 'test_banner_ad_unit_id',
                   ads_service.get('test_banner_ad_unit_id'))
        gen_string(root, 'test_interstitial_ad_unit_id',
                   ads_service.get('test_interstitial_ad_unit_id'))
      analytics_service = services.get('analytics_service')
      if analytics_service:
        analytics_property = analytics_service.get('analytics_property')
        if analytics_property:
          gen_string(root, 'ga_trackingId',
                     analytics_property.get('tracking_id'))
      # enable this once we have an example if this service being present
      # in the json data:
      maps_service_enabled = False
      if maps_service_enabled:
        maps_service = services.get('maps_service')
        if maps_service:
          maps_api_key = maps_service.get('api_key')
          if maps_api_key:
            for k in range(0, len(maps_api_key)):
              # generates potentially multiple of these keys, which is
              # the same behavior as the java plugin.
              gen_string(root, 'google_maps_key',
                         maps_api_key[k].get('maps_api_key'))

  tree = ElementTree.ElementTree(root)

  indent(root)

  if args.l:
    for package in sorted(packages):
      if package:
        sys.stdout.write(package + '\n')
  else:
    path = os.path.dirname(output_filename)

    if path and not os.path.exists(path):
      os.makedirs(path)

    if not args.plist:
      tree.write(output_filename, 'utf-8', True)
    else:
      with open(output_filename, 'w') as ofile:
        ofile.write(json_string)

  return 0

if __name__ == '__main__':
  sys.exit(main())