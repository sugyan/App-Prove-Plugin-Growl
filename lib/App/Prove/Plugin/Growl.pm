package App::Prove::Plugin::Growl;
use strict;
use warnings;

use Growl::Any;
our $VERSION = '0.03';

sub load {
    my ($class, $p) = @_;
    $p->{app_prove}->formatter('TAP::Formatter::GrowlNotify');

    my @args = @{ $p->{args} };
    my $passed = shift @args;
    my $failed = shift @args;
    $ENV{APP_PROVE_PLUGIN_GROWL_PASSED} = $passed if $passed;
    $ENV{APP_PROVE_PLUGIN_GROWL_FAILED} = $failed if $failed;
}

package TAP::Formatter::GrowlNotify;
use parent 'TAP::Formatter::Console';
use Class::Method::Modifiers;

after 'summary' => sub {
    my ($self, $aggregate, $interrupted) = @_;

    my $growl = Growl::Any->new(
        appname => 'App::Prove::Plugin::Growl',
        events => ['passed', 'failed'],
    );

    my $total  = $aggregate->total;
    my $passed = $aggregate->passed;

    if ($aggregate->all_passed) {
        $growl->notify('passed', 'PASS', 'All tests successful.', $ENV{APP_PROVE_PLUGIN_GROWL_PASSED});
    }
    if ($total != $passed or $aggregate->has_problems) {
        my $message = '';
        for my $test ($aggregate->descriptions) {
            my ($parser) = $aggregate->parsers($test);
            if (my @r = $parser->failed) {
                $message .= sprintf "$test (Wstat: %d Tests: %d Failed: %d)\n",
                    $parser->wait, $parser->tests_run, scalar $parser->failed;
            }
        }
        $growl->notify('failed', 'FAIL', $message, $ENV{APP_PROVE_PLUGIN_GROWL_FAILED});
    }
};

1;
__END__

=head1 NAME

App::Prove::Plugin::Growl -

=head1 SYNOPSIS

  use App::Prove::Plugin::Growl;

=head1 DESCRIPTION

App::Prove::Plugin::Growl is

=head1 AUTHOR

sugyan E<lt>sugi1982@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
