// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'flows/email_auth_flow_test.dart' as email_auth_flow;
import 'flows/email_link_flow_test.dart' as email_link_flow;
import 'flows/universal_email_sign_in_flow_test.dart'
    as universal_email_sign_in_flow;
import 'flows/phone_auth_flow_test.dart' as phone_auth_flow;
import 'widgets/email_form_test.dart' as email_form;
import 'views/forgot_password_view_test.dart' as forgot_password_view;

void main() {
  email_auth_flow.main();
  email_link_flow.main();
  universal_email_sign_in_flow.main();
  phone_auth_flow.main();
  email_form.main();
  forgot_password_view.main();
}
