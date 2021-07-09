#!/usr/bin/perl

use strict;
use warnings;
use feature qw(say);
use FindBin;
use lib $FindBin::Bin;
use parse_lshw;
use Data::Dumper;

## create object from original filename
#system("sudo lshw -json > ./lshw.json");
#my $lshw = new parse_lshw("./lshw.json");

# create object from default filename (input.json)
my $lshw = new parse_lshw("./input.json");

## parse json file to hash-data
my $data = $lshw->parse();
#say Dumper $data;

# output to json-text
say $lshw->_to_json();
