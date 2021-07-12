# parse_lshw library
Edit the output (JSON) of the 'lshw' command in a nice way

``` lshw ``` の出力をいい感じにパースして出力するツール

### parse_lshw.pm
 parsing library
### app.pl
 sample application

## How to install library and do it
```
# sudo yum install lshw
# sudo yum install perl-App-cpanminus
# sudo cpanm install JSON
$ git clone https://github.com/kiyotune/parse_lshw 
$ cd parse_lshw
$ ./app.pl 
```

## parse_lshw Class methods
### ```new```
 create class instance
### ```parse```
 parse and return hash object
### ```_to_json```
 output as json formatting
### ```_to_tsv```
 output as tab-separated-value formatting (redundant two-dimensional tabular format)
