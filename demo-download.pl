#!/usr/bin/perl

use File::Basename;

my $url = undef;
my $no_subdirs = 0;
my $archivetype = undef;
my $manual_download_url;
my @img_install;
my $img_autorun;
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
    elsif ($name eq "img-install") {
        push(@img_install,$value);
    }
    elsif ($name eq "img-autorun") {
        $img_autorun = $value;
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
    elsif ($url =~ m/\.exe$/i) {
        $archivetype = "exe";
    }
    elsif ($url =~ m/\.iso$/i) {
        $archivetype = "iso";
    }

    close(URL);

    my $dnname;

    if ($archivetype eq "exe") {
        $dnname = "_dnload_.$archivetype";
    }
    else {
        $dnname = "_download_.$archivetype";
    }

    if ( -f $dnname ) {
    }
    else {
        print "Final URL: $url\n";
        print "Download name: $dnname\n";
        print "Hit ENTER to proceed.\n";

        $x = <STDIN>;
        chomp $x;
        die unless $x eq "";

        my @args = ("wget","-O","$dnname.part","--continue","--",$url);

        $x = system(@args);
        die unless $x == 0;

        rename("$dnname.part",$dnname) || die;
    }
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
elsif ($archivetype eq "exe") { # standalone exe, do nothing
}
elsif ($archivetype eq "iso") {
}
else {
    print "Warning: I do not know how to unpack this archive\n";
}

my $img = undef;
my $mtoolspec = undef;

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

    if ($need eq "windows95") {
        $img = "win95";
        $mtoolspec = "win95\@\@32256";
    }
    elsif ($need eq "windows95osr2") {
        $img = "win95osr2";
        $mtoolspec = "win95osr2\@\@32256";
    }
    elsif ($need eq "windows98") {
        $img = "win98";
        $mtoolspec = "win98\@\@32256";
    }
}

if (@img_install > 0) {
    die unless defined $img;
    die unless defined $mtoolspec;
    die unless -f $img;

    for ($i=0;$i < @img_install;$i++) {
        $spec = $img_install[$i];
        # dest=source
        $name = undef;
        $value = undef;
        # cut
        $ci = index($spec,'=');
        next if $ci <= 0;
        $name = substr($spec,0,$ci);
        $value = substr($spec,$ci+1);
        next unless defined($name);
        next unless defined($value);
        next if $name eq "";
        next if $value eq "";
        # convert \ to /
        $name =~ s/\\/\//g;
        # remove leading /
        $name =~ s/^\///g;
        # do it
        die unless -f $value;
        $x = system("mcopy","-Q","-n","-m","-v","-o","-i",$mtoolspec,$value,"::".$name);
        die unless $x == 0;
    }

    if (defined($img_autorun) && $img_autorun ne "") {
        # at the moment I do not have the time or effort to generate Win95 compatible .LNK files
        # so we'll have to do for the time being running it with WIN.COM from AUTOEXEC.BAT
        $x = system("mcopy","-Q","-n","-m","-v","-o","-i",$mtoolspec,"::AUTOEXEC.BAT","autoexec.tmp");
        die unless $x == 0;

        open(A,">>autoexec.tmp") || die;
        print A "WIN C:".$img_autorun."\r\n";
        close(A);

        $x = system("mcopy","-Q","-n","-m","-v","-o","-i",$mtoolspec,"autoexec.tmp","::AUTOEXEC.BAT");
        die unless $x == 0;
    }
}

