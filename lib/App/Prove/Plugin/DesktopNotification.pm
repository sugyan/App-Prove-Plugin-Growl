package App::Prove::Plugin::DesktopNotification;
use strict;
use warnings;
use Log::Dispatch;
use Log::Dispatch::DesktopNotification;
our $VERSION = '0.01';

my $dispatcher;
my %status_icon = (
    'alert'   => 'AlertCautionIcon.icns',
    'warning' => 'AlertStopIcon.icns',
    'info'    => 'ToolbarInfo.icns',
);

sub _dispatcher {
    return $dispatcher if $dispatcher;

    $dispatcher = Log::Dispatch->new;
    $dispatcher->add(
        Log::Dispatch::DesktopNotification->new(
            name      => "notify",
            min_level => "debug",
            app_name  => "App::Prove::Plugin::DesktopNotification",
            title     => "Test Report",
            sticky    => 0,
        ));
    return $dispatcher;
}

sub _notify_summary {
    my $aggregate = shift;
    my $summary;
    my $non_zero_exit_status = 0;

    if ($aggregate->all_passed) {
        $summary = "ALL PASSED\n";
    } else {
        local $, = ",";
        my $total  = $aggregate->total;
        my $passed = $aggregate->passed;
        $summary = "${total} planned, only ${passed} passed.\n";

        my @t = $aggregate->descriptions;
        for my $t (@t) {
            $t =~ /(t\/.*$)/;
            my $tfile = $1;
            my ($parser) = $aggregate->parsers($t);
            if (my @r = $parser->failed()) {
                $summary .= "Failed test(s) in $tfile: @r\n";
            }
            if ( my $exit = $parser->exit ) {
                $summary .= "  Non-zero exit status: $tfile\n";
                $non_zero_exit_status = 1;
            }
        }
    }

    for (split(/\n(?!  )/, $summary )) {
        s/ +/ /gs;
        my $status = $non_zero_exit_status ? 'alert' : $aggregate->all_passed ? 'info' : 'warning';
        my $notify = _dispatcher->remove("notify");
        $notify->{icon_file} = '/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/' .
            ($status_icon{$status} || 'ToolbarInfo.icns');
        _dispatcher->add($notify);
        _dispatcher->$status("$_\n");
    }
}

sub load {
    no warnings 'redefine';
    *my_runtest = sub {
        my ( $self, $args, $harness_class, @tests ) = @_;
        my $harness = $harness_class->new($args);

        my $state = $self->state_manager;

        $harness->callback(
            after_test => sub {
                $state->observe_test(@_);
            }
        );

        $harness->callback(
            after_runtests => sub {
                $state->commit(@_);
                _notify_summary(@_);
            }
        );

        my $aggregator = $harness->runtests(@tests);

        return !$aggregator->has_errors;
    };
    *App::Prove::_runtests = \&my_runtest;

    return 1;
}

1;
__END__

=head1 NAME

App::Prove::Plugin::DesktopNotification -

=head1 SYNOPSIS

  use App::Prove::Plugin::DesktopNotification;

=head1 DESCRIPTION

App::Prove::Plugin::DesktopNotification is

=head1 AUTHOR

sugyan E<lt>sugi1982@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
