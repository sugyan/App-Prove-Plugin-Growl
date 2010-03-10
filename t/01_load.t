use strict;
use Test::More tests => 3;

BEGIN { use_ok 'App::Prove::Plugin::Growl' }
can_ok( 'App::Prove::Plugin::Growl', 'load' );

use App::Prove;
use constant PLUGINS => 'App::Prove::Plugin';

my $app = App::Prove->new;
$app->process_args('-PGrowl');
$app->_load_extensions( $app->plugins, PLUGINS );

ok 1;
