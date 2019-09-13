#!/usr/bin/perl

use File::Basename;

my $url = undef;
my $no_subdirs = 0;
my $archivetype = undef;
my $manual_download_url;
my @needs;

my $this_script_dir = dirname($0);
die unless $this_script_dir ne "";
die unless -d $this_script_dir;

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
    elsif ($name eq "manual download url") {
        $manual_download_url = $value;
    }
    elsif ($name eq "no-subdirs") {
        $no_subdirs = 1;
    }
    elsif ($name eq "archivetype") {
        $archivetype = $value;
    }
    elsif ($name eq "needs") {
        push(@needs,$value);
    }
}

# some games don't let you directly download the ZIP, you have to visit their site
if (defined $manual_download_url) {
    if (!( -f "_download_.$archivetype" )) {
        print "How to obtain this game:\n";
        print "Visit this URL: $manual_download_url\n";
        print "Download the game, then place it here and name it _download_.$archivetype and run this script again.\n";
        exit 1;
    }
}
else {
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
}

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

# needs?
for ($i=0;$i < @needs;$i++) {
    my $need = $needs[$i];

    my $file = $this_script_dir."/needs-$need.zip";

    die "cannot find need $need ($file)" unless -f $file;

    print "Unpacking need $need...\n";
    @args = ("unzip");
    push(@args,"-q");
    push(@args,"-o",$file); # use InfoZip
    $x = system(@args);
    die unless $x == 0;
}

