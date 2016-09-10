#!/usr/bin/perl

use strict;
use warnings;
use autodie;

use XML::LibXML;
use YAML qw(Dump);

my $SRC = 'asthickastwoshortplanks-markfowler039sblog.wordpress.2016-09-10.001.xml';

########################################################################

my $dom = XML::LibXML->load_xml( location => $SRC );
foreach my $post ($dom->findnodes('/rss/channel/item')) {
    next unless $post->findvalue('./wp:status') eq 'publish';
    next unless $post->findvalue('./wp:post_type') eq 'post';

    my $raw_title = $post->findvalue('./title');
    my $raw_date = $post->findvalue('./wp:post_date');

    my $header = {
        layout => 'post',
        title => $raw_title,
        date => $raw_date,
    };

    my $output;
    $output .= Dump( $header );
    $output .= "---\n";

    $output .= $post->findvalue('./content:encoded');
    $output .= "\n";

    my $filename = lc($raw_title);
    $filename =~ s/[^a-z0-9.]/-/g;
    $filename = ($raw_date =~ s/ .*//r) . "-imported-$filename.html";

    open my $fh, ">:utf8", $filename;
    print {$fh} $output;
}
