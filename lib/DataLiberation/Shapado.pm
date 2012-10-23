package DataLiberation::Shapado;
# ABSTRACT: liberate data from http://yoursite.shapado.com
use strict;
use warnings;
use 5.010_000;
use JSON;
use Data::Dumper;
use HTML::TreeBuilder;

my $datadir = $ARGV[0] || 't/data/input';
my $outdir  = $ARGV[1] || 't/data/output/questions';

if ( !-d $outdir ) {
    mkdir $outdir or die "couldn't mkdir $outdir: $!";
}

my $users_by_id;
my $users_file = "$datadir/users.js";
local $/;
open( my $ufh, '<', $users_file );
my $users_json = <$ufh>;
my $users_dd   = decode_json($users_json);
#print Dumper $users_dd;
my $content      = $users_dd->{html};
my $tree         = HTML::TreeBuilder->new->parse($content)->eof;
my $body_content = $tree->look_down( _tag => 'img' );
# <img alt="philipdurbin" class="gravatar" src="https://shapado.com:443/_files/users/avatar/5080bfa897cfef61a2000546.png" style="height: 32px" title="philipdurbin" />
my $username = $body_content->attr('title');
my $src      = $body_content->attr('src');
my ($uuid) = $src =~ qr{avatar/(.*)[.]png};
#say $uuid;
$$users_by_id{$uuid} = { username => $username };

for my $user ( keys %$users_by_id ) {
    $$users_by_id{$user}{foo} = 42;
    my $username = $$users_by_id{$user}{username};

    my $user_file = "$datadir/users/$username.json";
    local $/;
    open( my $fh, '<', $user_file );
    my $user_json = <$fh>;
    my $user_dd   = decode_json($user_json);
    $$users_by_id{$user} = $user_dd;

}

my $answers_file = "$datadir/answers.json";
local $/;
open( my $afh, '<', $answers_file );
my $answers_json = <$afh>;
my $answers_dd   = decode_json($answers_json);
#print Dumper $answers_dd;

my $answers_by_id;

for my $answer (@$answers_dd) {
    my $body    = $answer->{body};
    my $_id     = $answer->{_id};
    my $user_id = $answer->{user_id};
    my $author  = $users_by_id->{$user_id}{name} || $user_id;
    push @{ $answers_by_id->{ $answer->{question_id} } },
      { id => $_id, body => $body, author => $author };
}
#print Dumper $answers_by_id;

my $questions_file = "$datadir/questions.json";
local $/;
open( my $qfh, '<', $questions_file );
my $questions_json = <$qfh>;
my $questions_dd   = decode_json($questions_json);

my $ititle = "---\ntitle: Questions\nlayout: default\n---\n";
my $ibody;

for my $q ( @{$questions_dd} ) {

    my $title      = $q->{title};
    my $_id        = $q->{_id};
    my $slug       = $q->{slug};
    my $body       = $q->{body};
    my $user_id    = $q->{user_id};
    my $created_at = $q->{created_at};
    my $author     = $users_by_id->{$user_id}{name} || $user_id;

    my $jtitle = "---\ntitle: $title\nlayout: default\n---\n";

    my $answers = @{$answers_by_id}{$_id};
    my $acontent;

    if ($answers) {
        my $count = 1;
        for my $answer (@$answers) {
            $acontent .=
              "## Answer 1 by $answer->{author}\n\n" . $answer->{body} . "\n";
            $count++;
        }
    }
    else {
        $acontent = 'No answers yet';
    }

    my $jbody =
      $body . "\n\n*Asked by $author on $created_at*\n" . "\n<hr>\n$acontent";
    my $content = $jtitle . $jbody;
    say "$_id: $slug";
    $ibody .= "- [$title]($slug)\n";
    my $output_file = "$outdir/$slug.md";
    local $/;
    open( my $fh, '>', $output_file );
    print $fh $content;

}

my $icontent = $ititle . $ibody;

# FIXME: stop using system()
system("echo '$icontent' > $outdir/index.md");

1;
