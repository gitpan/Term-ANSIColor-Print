package Term::ANSIColor::Print;

$VERSION = '0.01';

use strict;
use warnings;
use vars qw( $AUTOLOAD );

my ($COLOR_REGEX,$SUB_COLOR_REGEX,%ANSI_CODE_FOR);
{
    use Readonly;

    Readonly $COLOR_REGEX => qr{
        \A ( . \[\d+m .*? . \[0m ) \z
    }xms;

    Readonly $SUB_COLOR_REGEX => qr{
        \A ( .+? )
           ( . \[\d+m .* . \[0m )
           (?! . \[0m )
           ( .+ ) \z
    }xms;

    # http://en.wikipedia.org/wiki/ANSI_escape_code
    Readonly %ANSI_CODE_FOR => (
        black     => 30,
        blue      => 94,
        bold      => 1,
        cyan      => 96,
        green     => 92,
        grey      => 37,
        magenta   => 95,
        red       => 91,
        white     => 97,
        yellow    => 93,
        conceal   => 8,
        faint     => 2,
        italic    => 3,
        negative  => 7,
        positive  => 27,
        reset     => 0,
        reveal    => 28,
        underline => 4,
        normal    => {
            foreground => 39,
            background => 99,
        },
        blink     => {
            slow  => 5,
            rapid => 6,
        },
        light => {
            black => 90,
        },
        double => {
            underline => 21,
        },
        normal => {
            intensity => 22,
        },
        no => {
            underline => 24,
            blink     => 25,
        },
        dark => {
            red     => 31,
            green   => 32,
            yellow  => 33,
            blue    => 34,
            magenta => 35,
            cyan    => 36,
        },
        on => {
            red     => 101,
            green   => 102,
            yellow  => 103,
            blue    => 104,
            magenta => 105,
            cyan    => 106,
            white   => 107,
            normal  => 109,
            black   => 40,
            grey    => 47,
            light   => {
                black => 100,
            },
            dark => {
                red     => 41,
                green   => 42,
                yellow  => 43,
                blue    => 44,
                magenta => 45,
                cyan    => 46,
                normal  => 49,
            },
        },
    );
}

sub new {
    my $class = shift;
    my %args = @_;

    my $self = bless {
        output => $args{output} || 'return',
        eol    => $args{eol} || "",
        pad    => $args{pad} || "",
    }, $class;

    return $self;
}

sub AUTOLOAD {
    my ($self,@strings) = @_;

    my @tokens = split /_/, ( split /::/, $AUTOLOAD )[-1];

    my $color_start = "";
    my $color_end   = "\x{1B}[0m";

    my $code_for_rh = \%ANSI_CODE_FOR;

    TOK:
    for my $token (@tokens) {

        my $code = $code_for_rh->{$token};

        if ( ref $code eq 'HASH' ) {
            $code_for_rh = $code;
            next TOK;
        }

        if ( !$code ) {
            warn "unrecognized token: $token";
            next TOK;
        }

        $color_start .= "\x{1B}[${code}m";
    }

    my @color_strings;

    for my $string ( @strings ) {

        # pre text ESC sub text ESC end text
        if ( $string =~ $SUB_COLOR_REGEX ) {

            my $pre
                = $1
                ? $color_start . $1 . $color_end
                : "";

            my $sub = $2;

            my $end
                = $3
                ? $color_start . $3 . $color_end
                : "";

            $string
                = $pre
                . $sub
                . $end;
        }

        # no color ESC
        elsif ( $string !~ $COLOR_REGEX ) {

            $string
                = $color_start
                . $string
                . $color_end;
        }

        # else ESC text ESC

        push @color_strings, $string;
    }

    $strings[-1] .= $self->{eol};

    my $string = join $self->{pad}, @strings;

    if ( ref $self->{output} eq 'GLOB' ) {

        print { $self->{output} } $string;
    }

    return $string;
}

sub DESTROY {
    return;
}

1;

__END__

=head1 NAME

Term::ANSIColor::Print - Create and/or print strings with ANSI color markup.

=head1 SYNOPSIS

  use Term::ANSIColor::Print;

  my $pad = Term::ANSIColor::Print->new();

  my $string = Term::ANSIColor::Print->new(
      pad => $pad->on_dark_red(' '),
  );

  my $print = Term::ANSIColor::Print->new(
      output => \*STDOUT,
      eol    => "\n",
  );

  # concatenate padded with spaces on dark red background
  my $colorful_text = $string->green_on_dark_red(
      '',
      'one',
      $string->bold_underline_yellow_on_dark_cyan('two'),
      $string->white_on_dark_green('three'),
      'four',
      '',
  );

  # print to STDOUT
  $print->black_on_white( ' zero ' . $colorful_text . ' five ' );

  # HTML approximation

=begin html

  <div style="background-color:black;padding:15px;width:50%;">

  <table cellpadding="1" cellspacing="0"><tr>
    <td style="color:black;background-color:white;">&nbsp;zero&nbsp;</td>
    <td style="color:green;background-color:red;">&nbsp;one&nbsp;</td>
    <td style="color:yellow;background-color:cyan;"><u><b>two</b></u></td>
    <td style="background-color:red;">&nbsp;</td>
    <td style="color:white;background-color:green;">three</td>
    <td style="color:green;background-color:red;">&nbsp;four&nbsp;</td>
    <td style="color:black;background-color:white;">&nbsp;five&nbsp;</td>
  </tr></table>

  </div>

=end html

=head1 DESCRIPTION

This is a natural language way of indicating how you want your strings to look.

=head2 METHODS

Methods are all dynamic. The methods you invoke are underscore separated keywords
which you take from this lexicon:

=over

=item *
black

=item *
blink + slow or rapid

=item *
blue

=item *
bold

=item *
conceal

=item *
cyan

=item *
dark

=item *
double

=item *
faint

=item *
green

=item *
grey

=item *
intensity

=item *
italic

=item *
light_black

=item *
magenta

=item *
negative

=item *
no + underline or blink

=item *
normal + foreground or background

=item *
on - prefixes background spec

=item *
positive

=item *
red

=item *
reset

=item *
reveal

=item *
underline

=item *
white

=item *
yellow

=back

=head1 LIMITATIONS

Not all combinations or codes may be supported on your Terminal application.

This is alpha code and is likely to have bugs. I'm happy to hear about them.

=head1 AUTHOR

Dylan Doxey, E<lt>dylan.doxey@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Dylan Doxey

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
