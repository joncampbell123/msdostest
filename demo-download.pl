#!/usr/bin/perl

my $url = undef;
my $archivetype = undef;

open(URL,"__DOWNLOAD__") || exit 0;
foreach my $line (<URL>) {
    my $name,$value,$i;
    chomp $line;

    $i = index($line,'=');
    next if $i <= 0;

    $name = substr($line,0,$i);
    $value = substr($line,$i+1);

    if ($name eq "url") {
        $url = $value;
    }
    elsif ($name eq "archivetype") {
        $archivetype = $value;
    }
}
exit 0 if $url eq "";

if ($url =~ m/\.zip$/i) {
    $archivetype = "zip";
}

close(URL);

print "Final URL: $url\n";
print "Hit ENTER to proceed.\n";

$x = <STDIN>;
chomp $x;
die unless $x eq "";

my @args = ("wget","-O","_download_.$archivetype","--continue","--",$url);

$x = system(@args);
die unless $x == 0;

# unpack the ZIP archive
if ($archivetype eq "zip") { # .zip, or .ZIP, or whatever
    @args = ("unzip","-o","_download_.zip"); # use InfoZip
    $x = system(@args);
    die unless $x == 0;
}
else {
    print "Warning: I do not know how to unpack this archive\n";
}

