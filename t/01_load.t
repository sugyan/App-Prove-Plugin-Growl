use strict;
use Test::More tests => 3;

BEGIN { use_ok 'App::Prove::Plugin::DesktopNotification' }
can_ok( 'App::Prove::Plugin::DesktopNotification', 'load' );

use App::Prove;
use constant PLUGINS => 'App::Prove::Plugin';

my $app = App::Prove->new;
$app->process_args('-PDesktopNotification');
$app->_load_extensions( $app->plugins, PLUGINS );

ok 1;
