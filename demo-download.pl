#!/usr/bin/perl

my $url = undef;

open(URL,"__DOWNLOAD__") || exit 0;
foreach my $line (<URL>) {
    my $name,$value,$i;
    chomp $line;

    $i = index($line,'=');
    next if $i <= 0;

    $name = substr($line,0,$i);
    $value = substr($line,$i+1);
}
exit 0 if $url eq "";
close(URL);

print "Final URL: $url\n";
print "Hit ENTER to proceed.\n";

$x = <STDIN>;
chomp $x;
die unless $x eq "";

my @args = ("wget","-O","_download_.zip","--continue","--",$url);

$x = system(@args);
die unless $x == 0;

# unpack the ZIP archive
if ($relpath =~ m/\.zip$/i) { # .zip, or .ZIP, or whatever
    @args = ("unzip","-o","_download_.zip"); # use InfoZip
    $x = system(@args);
    die unless $x == 0;
}
else {
    print "Warning: I do not know how to unpack this archive\n";
}

