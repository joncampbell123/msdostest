#!/usr/bin/perl

my $url = undef;
my $no_subdirs = 0;
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
    elsif ($name eq "no-subdirs") {
        $no_subdirs = 1;
    }
    elsif ($name eq "archivetype") {
        $archivetype = $value;
    }
}
exit 0 if $url eq "";

if ($url =~ m/\.zip$/i) {
    $archivetype = "zip";
}
elsif ($url =~ m/\.rar$/i) {
    $archivetype = "rar";
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
    @args = ("unzip");
    push(@args,"-j") if $no_subdirs == 1;
    push(@args,"-o","_download_.zip"); # use InfoZip
    $x = system(@args);
    die unless $x == 0;
}
elsif ($archivetype eq "rar") { # .rar, or .RAR, or whatever
    @args = ("unrar");
    push(@args,"e") if $no_subdirs == 1;
    push(@args,"x") if $no_subdirs == 0;
    push(@args,"_download_.rar"); # use InfoZip
    $x = system(@args);
    die unless $x == 0;
}
else {
    print "Warning: I do not know how to unpack this archive\n";
}

