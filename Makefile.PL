use inc::Module::Install;
name 'App-Prove-Plugin-DesktopNotification';
all_from 'lib/App/Prove/Plugin/DesktopNotification.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
