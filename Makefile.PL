use inc::Module::Install;
name 'App-Prove-Plugin-Growl';
all_from 'lib/App/Prove/Plugin/Growl.pm';

requires 'Growl::Any' => '0.07';
requires 'Class::Method::Modifiers' => '1.07';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
