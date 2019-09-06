#!/usr/bin/perl
#
# ./look-for-duplicate.pl <topdir> <original rel dir>
my $topdir = shift @ARGV;
my $original = shift @ARGV;

die unless -d $topdir;
chdir $topdir || die;
die unless $original =~ m/^\.\//;
die "$original not a dir" unless -d $original;

# pick something to match by.
# pick the LARGEST executable file (EXE or COM)
$what="";
$whatsz=0;
opendir(D,$original) || die;
while (my $file = readdir(D)) {
    $path = "$original/$file";
    next unless $file =~ m/\.(exe|com)$/i;
    die unless -e $path;
    next unless -f $path;

    next if $file =~ m/^demosite\.com$/i;

    $sz = -s $path;

    if ($whatsz < $sz) {
        $whatsz = $sz;
        $what = $file;
    }
}
closedir(D);

exit 0 if $whatsz == 0;

$path = "$original/$what";
print "Looking for $what size $whatsz\n";
print "To see what matches $path\n";

open(M,"find -iname '$what' |") || die;
while (my $match = <M>) {
    chomp $match;
    die unless -e $match;
    next unless -f $match;

    # don't match the same path
    $x1=`realpath -- '$path'`; chomp $x1;
    $x2=`realpath -- '$match'`; chomp $x2;
    next if $x1 eq "";
    next if $x2 eq "";
    next if $x1 eq $x2;

    # basename
    $matchbase = substr($match,0,rindex($match,'/'));
    next if $matchbase eq "";
    next unless -d $matchbase;
    next if $matchbase =~ m/\.DUPLICATE$/;

    # symlink ignore
    next if -l $original;
    next if -l $matchbase;

    # does it match?
    $x = system("$topdir/check-duplicate.pl",$matchbase,$original);
    next unless $x == 0;

    # symlink
    $origsym = "";
    $x = $matchbase;
    $x =~ s/\/+/\//g;
    $x =~ s/^\.\///g;
    @a = split(/\//,$x);
    for ($i=0;$i < (@a - 1);$i++) {
        $origsym .= "/" if $origsym ne "";
        $origsym .= "..";
    }
    $origsym .= "/" if $origsym ne "";
    $x = $original;
    $x =~ s/^\.\///g;
    $origsym .= $x;
    die "$origsym is wrong" unless -d "$matchbase/../$origsym";

    # paranoid
    $x1=`realpath -- '$original'`; chomp $x1;
    $x2=`realpath -- '$matchbase/../$origsym'`; chomp $x2;
    next if $x1 eq "";
    next if $x2 eq "";
    print " - orig: $x1\n";
    print "   sym:  $x2\n";
    die unless $x1 eq $x2;

    # found one
    print "$matchbase looks like one.\n";
    print "  Symlink would be to $origsym\n";
    print "  Replace? "; $|++;
    $resp = <STDIN>; chomp $resp;

    if ($resp eq "y") {
        # replace directory with symlink
        system("mv","-v","-n",$matchbase,"$matchbase.DUPLICATE") == 0 || die;
        # symlink
        system("ln","-s",$origsym,$matchbase) == 0 || die;
    }
}
close(M);
