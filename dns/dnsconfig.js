var REG_NONE = NewRegistrar('none');    // No registrar.
var DNS_BIND = NewDnsProvider('bind');  // ISC BIND.

D('*', REG_NONE, DnsProvider(DNS_BIND),
    A('@', '8.8.8.8'),
    A('@', '8.8.4.4')
);
