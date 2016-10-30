# Collect asterisk call metrics in Carbon

This is a compilation of short python scripts that interact with an asterik telephony server using the AMI over a telnet connection.

The data it collects from there is then sent to the local Carbon service.

You need Asterisk 1.8+ or xivo 13.07+

Copy the files into a directory of choice on a machine that can connect to Asterisk and Carbon and make sure the permissions are set correctly. Add AMI users in asterisks. The DADHI user needs read-permissions for "call" and the general one needs write-permissions for "command". For more information about this please consult the Asterisk documentation.
Configuration

Enter the details for the servers, including host, port, username (asterisk only) and secret (asterisk only).

this part is provided by [niklasR/zweig](https://github.com/niklasR/zweig)
