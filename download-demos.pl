#!/usr/bin/perl
my $skip = '';
my $suffix="";
my $suffic="";
my $top=`pwd`; chomp $top;

if ($ARGV[0] eq "svn") {
    $suffix=".svn";
    $suffic="_SVN";
}
elsif ($ARGV[0] eq "xdos") {
    $suffix=".xdos";
    $suffic="_XDOS";
}
elsif ($ARGV[0] eq "svndos") {
    $suffix=".svndos";
    $suffic="_SVNDOS";
}
elsif ($ARGV[0] eq "svnbochs") {
    $suffix=".svnbochs";
    $suffic="_SVNBOCHS";
}
elsif ($ARGV[0] eq "qemu") {
    $suffix=".qemu";
    $suffic="_QEMU";
}

open(X,"find -type d | sort |") || die;
open(C,">","pick-one$suffix.cache") || die;

sub escape_shell($) {
    my $x = shift(@_);
    $x =~ s/([^a-z])/\\$1/gi;
    return $x;
}

while (my $path = <X>) {
    chomp $path;
    next if $path eq ".";
    next if $path eq "./";
    next unless -d $path;
    next if $path =~ m/\'/;
    next if ($skip ne '' && (substr($path,0,length($skip)) eq $skip));

    # TEMP: we only want 1995 and earlier demos
#    next unless ($path =~ m/\/199[0-5]\// || $path =~ m/\/198[0-9]\//);

    # not our GIT repo!
    next if $path eq "./.git";
    next if $path =~ m/\/\.git\//;

    # skip Amiga demos, we can't run them
    next if $path =~ m/\/amiga\/(demo|in64|in40|in4k)\//;

    # no MOD music executables
    next if $path =~ m/\/m4ch\//;

    # skip if it already has __PASS__ or __FAIL__
    # 2018/02/09: we now require PASS/FAIL to indicate the commit!
    next if (
        ( -f ("$path/__PASS$suffic"."__") && ( -s ("$path/__PASS$suffic"."__")) > 4) ||
        ( -f ("$path/__FAIL$suffic"."__") && ( -s ("$path/__FAIL$suffic"."__")) > 4)
    );

    # skip it if it's Windows only
    next if (
        ( -f ("$path/__WINDOWS$suffic"."__") && ( -s ("$path/__WINDOWS$suffic"."__")) > 4)
    );

    # skip unless it has an EXE or COM file OR it is already marked
    if ( -f ("$path/__PASS$suffic"."__") || -f ("$path/__FAIL$suffic"."__") ) {
    }
    else {
        $path_esc=escape_shell($path);
        $x=`cd $path_esc && ls -- *.exe *.EXE *.com *.COM 2>/dev/null | head -n 1`; chomp $x;

        if ($x eq "") {
            if ($path =~ m/\.zip$/i && !( -f "$path/__UNPACKED__") ) {
                print "Downloading/unpacking $path\n";
                $shell="$top/demo-download.pl";
                system("cd $path_esc && (echo | '$shell')") == 0 || die;
            }

            next;
        }
    }

    $skip = $path;
}
close(X);

