use inc::Module::Install;
name 'App-Prove-Plugin-Growl';
all_from 'lib/App/Prove/Plugin/Growl.pm';

requires 'Log::Dispatch' => '2.26';
requires 'Log::Dispatch::DesktopNotification' => 0.01;

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
