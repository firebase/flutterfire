import 'auth/flows/email_auth_flow_test.dart' as email_auth_flow;
import 'auth/flows/email_link_flow_test.dart' as email_link_flow;
import 'auth/flows/universal_email_sign_in_flow_test.dart'
    as universal_email_sign_in_flow;
import 'auth/flows/phone_auth_flow_test.dart' as phone_auth_flow;
import 'auth/widgets/email_form_test.dart' as email_form;

void main() {
  email_auth_flow.main();
  email_link_flow.main();
  universal_email_sign_in_flow.main();
  phone_auth_flow.main();
  email_form.main();
}
