#!/usr/bin/perl
my $dir = `pwd`; chomp $dir;
my @dirs = split(/\//,$dir);

# scan upwards until "ftp.scene.org"
for ($i=@dirs-1;$i >= 0;$i--) {
    $elem = $dirs[$i];
    last if $elem eq "ftp.scene.org";
}
die unless $i >= 0;
$i++;

my $relpath;
while ($i < @dirs) {
    $elem = $dirs[$i];
    $relpath .= "/" . $elem;
    $i++;
}

$relpath =~ s/\/pub\//\//;

# Fix your US mirror! Use the NL one in the meantime
$baseurl = "http://files.scene.org/get:nl-http";

# Uncomment this when they fix their US mirror
#$baseurl = "http://files.scene.org/get";

$url = $baseurl . $relpath;

print "Relative path: $relpath\n";
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

