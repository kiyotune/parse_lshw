package parse_lshw;

use strict;
use warnings;
use feature qw(say);
use utf8;
use JSON;
use FindBin;
use Data::Dumper;

our $version = "0.9.0";

############################################################################
### new
############################################################################
sub new{
	my $class = $_[0];
  my $self;

  if ($#_ > 0){
    $self->{input} = $_[1];
  }else{
    $self->{input} = "$FindBin::Bin/input.json";
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

	# trimming
	map {
		delete($_->{capabilities});
		delete($_->{configuration});
		delete($_->{children});
		delete($_->{claimed});
	} @devices;	

	return $self->{data};
}

############################################################################
### parse
############################################################################
sub get_devices {
	my $parent = shift;
	my $devices = shift;
	my @includes = (
		["firmware", "memory"],
		["cpu:", "processor"],
		["display", "display"],
		["bank:", "memory"],
		["disk:", "disk"],
		["network", "network"],
	);

	# list::includes only
	if(grep {$parent->{id}=~/^$_->[0]/ && $parent->{class}=~/^$_->[1]/} @includes){
		# id:no 
		my ($id, $no) = split(/:/, $parent->{id});
		if(!$no){
			my @items = grep {$_->{class} eq $parent->{class} && $_->{id} eq $id} @{$devices};
			if($#items >= 0){
				@items = sort {$b->{no} <=> $a->{no}} @items;
				$no = $items[0]->{no} + 1;
			}else{
				$no = 0;
			}
		}
		$parent->{id} = $id;
		$parent->{no} = $no;

		push(@{$devices}, $parent);
	}

	if(exists($parent->{children})){
		foreach my $child (@{$parent->{children}}){
			get_devices($child, $devices);
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

############################################################################
### to_tsv
############################################################################
sub _to_tsv {
	my $self = shift;
	my $tsv_text = "";
	if(exists($self->{data})){
		my $data = $self->{data};
		my $hostname = [keys(%{$data})]->[0];
		
		my $items = $data->{$hostname};
		$tsv_text.="$hostname\tvendor\t\t$items->{vendor}\n";
		$tsv_text.="$hostname\tproduct\t\t$items->{product}\n";
		$tsv_text.="$hostname\tserial\t\t$items->{serial}\n";
		
		my $devices = $items->{devices};
		foreach my $device (@{$devices}){
			my $name = "$hostname\tdevices\t$device->{class}\t$device->{id}\t$device->{no}";
			foreach my $k (grep {!/id|class|no/} keys(%{$device})){
				$tsv_text.="$name\t$k\t$device->{$k}\n";
			}
		}
	}
	return $tsv_text;
}
1;
