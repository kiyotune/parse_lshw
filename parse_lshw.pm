package parse_lshw;

use strict;
use warnings;
use feature qw(say);
use utf8;
use JSON;
use Data::Structure::Util qw(unbless);
use FindBin;
use Data::Dumper;

our $version = "0.9.0";
our $DIR = $FindBin::Bin;

############################################################################
### new
############################################################################
sub new{
	my $class = $_[0];
  my $self;

  if ($#_ > 0){
    $self->{input} = $_[1];
  }else{
    $self->{input} = "$DIR/input.json";
  }

  bless $self;
  return $self;
}

############################################################################
### parse
############################################################################
sub parse{
  my $self = shift;
	my @devices;

	if(-f $self->{input}){
		my $json_text = `cat $self->{input}`;
		$json_text =~ s/^\s+|\s+\n$//g;

		my $json = decode_json($json_text) or die("[error] cannot open file - $self->{input}");
		$self->{data}->{$json->{id}}->{product} = $json->{product};	
		$self->{data}->{$json->{id}}->{vendor} = $json->{vendor};	
		$self->{data}->{$json->{id}}->{serial} = $json->{serial};	
		$self->{data}->{$json->{id}}->{devices} = get_devices($json, \@devices);
	}else{
		die("[error] cannot open file - $self->{input}");
	}

	return $self->{data};
}

sub get_devices {
	my $parent = shift;
	my $devices = shift;
	my @include = (
		["firmware", "memory"],
		["cpu:", "cpu"],
		["display", "display"],
		["bank:", "memory"],
		["disk:", "disk"],
		["network", "network"],
	);

	if(exists($parent->{children})){
		foreach my $child (@{$parent->{children}}){
			get_devices($child, $devices);
		}
	}else{
		if(grep {$parent->{id}=~/^$_->[0]/ && $parent->{class}=~/^$_->[1]/} @include){
			push(@{$devices}, $parent);
		}
	}

	return($devices);
}

############################################################################
### to_json
############################################################################
sub _to_json {
	my $self = shift;
	my $json_text = "";
	if(exists($self->{data})){
		$json_text = encode_json($self->{data});
	}
	return $json_text;
}

1;
