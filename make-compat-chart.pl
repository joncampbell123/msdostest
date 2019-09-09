#!/usr/bin/perl
my $line;

open(H,">compat-chart.html") || die;

print H "<html>\n";
print H "<head>\n";
print H "<title>DOS game compat testing chart</title>\n";
print H "<style>\n";
print H ".passfail_WINDOWS { background-color: #DFDFBF; text-align: center; vertical-align: top; }\n";
print H ".passfail_PASS { background-color: #7FFF7F; text-align: center; vertical-align: top; }\n";
print H ".passfail_FAIL { background-color: #FF7F7F; text-align: center; vertical-align: top; }\n";
print H ".passfail_NA { background-color: #DFDFDF; text-align: center; vertical-align: top; }\n";
print H ".testing_header { background-color: #BFBFBF; }\n";
print H "td pre { white-space: pre-line; word-break: normal; word-wrap: normal; }\n";
print H "td a { color: black; }\n";
print H "pre { padding: 0px; margin: 0px; }\n";
print H "</style>\n";
print H "</head>\n";
print H "<body>\n";

print H "DOSBox game compat testing chart<br>\n";
print H "DOS game testing repository: <a target=\"_blank\" href=\"https://github.com/joncampbell123/msdostest\">https://github.com/joncampbell123/msdostest</a><br>\n";

print H "<br>\n";

print H "DOSBox-X refers to the <a target=\"_blank\" href=\"http://dosbox-x.com/\">DOSBox-X project</a><br>\n";
print H "DOSBox-SVN refers to the <a target=\"_blank\" href=\"https://www.dosbox.com/\">DOSBox project</a><br>\n";
print H "DOSBox-X-DOS refers to the <a target=\"_blank\" href=\"http://dosbox-x.com/\">DOSBox-X project</a> booting an MS-DOS system.<br>\n";
print H "DOSBox-SVN-DOS refers to the <a target=\"_blank\" href=\"https://www.dosbox.com/\">DOSBox project</a> booting an MS-DOS system.<br>\n";
print H "Bochs-SVN refers to the <a target=\"_blank\" href=\"https://sourceforge.net/projects/bochs/\">Bochs project</a> booting an MS-DOS system disk.<br>\n";
print H "QEMU refers to the <a target=\"_blank\" href=\"https://www.qemu.org/\">QEMU project</a> booting an MS-DOS system disk.<br>\n";
print H "<br>\n";

print H "<table cellpadding=0 cellspacing=0>\n";
print H "<thead class=\"testing_header\">\n";
print H "<tr>\n";
print H "<td style=\"min-width: 6em; text-align: center;\">DOSBox-X</td>";
print H "<td style=\"min-width: 6em; text-align: center;\">DOSBox-SVN</td>";
print H "<td style=\"min-width: 6em; text-align: center;\">DOSBox-X-DOS</td>";
print H "<td style=\"min-width: 8em; text-align: center;\">DOSBox-SVN-DOS</td>";
print H "<td style=\"min-width: 6em; text-align: center;\">Bochs-SVN</td>";
print H "<td style=\"min-width: 4em; text-align: center;\">QEMU</td>";
print H "<td>Demo</td>";
print H "</tr>\n";
print H "</thead>\n";

print H "<tbody>\n";

sub escape_shell($) {
    my $x = shift(@_);
    $x =~ s/([^a-z])/\\$1/gi;
    return $x;
}

my $totalcount = 0;
my $tot_pc98 = 0;
my $tot_x = 0,$pass_x = 0;
my $tot_svn = 0,$pass_svn = 0;
my $tot_xdos = 0,$pass_xdos = 0;
my $tot_svndos = 0,$pass_svndos = 0;
my $tot_bochs = 0,$pass_bochs = 0;
my $tot_qemu = 0,$pass_qemu = 0;

$count = 0;
$list = "pick-one.cache  pick-one.qemu.cache  pick-one.svnbochs.cache  pick-one.svn.cache  pick-one.svndos.cache  pick-one.xdos.cache";
#open(S,"find -type d | sort |") || die;
open(S,"(find -type d; find -type l; cat $list) | sort | uniq |") || die;
while ($line = <S>) {
    chomp $line;

    next unless -d $line;

    # some are symlinks
    $symlink_to = undef;
    if ( -l $line ) {
        $symlink_to = readlink($line);
        die "path $line" unless defined($symlink_to);
    }

    $line =~ s/^\.\///;
    $disp_line = $line;

    my $pass_dosbox_x = undef;
    my $pass_dosbox_x_rev = undef;
    my $pass_dosbox_x_url = undef;
    my $pass_dosbox_x_rev_file = undef;

    die unless !defined($pass_dosbox_x);
    die unless !defined($pass_dosbox_x_url);
    die unless !defined($pass_dosbox_x_rev);
    die unless !defined($pass_dosbox_x_rev_file);

    if ( -f "$line/__PASS__" ) {
        $tot_x++;
        $pass_x++;
        $pass_dosbox_x = "PASS";
        $pass_dosbox_x_rev_file = "$line/__PASS__";
    }
    if ( -f "$line/__FAIL__" ) {
        $tot_x++;
        $pass_dosbox_x = "FAIL";
        $pass_dosbox_x_rev_file = "$line/__FAIL__";
    }
    if ( -f "$line/__WINDOWS__" ) {
        $pass_dosbox_x = "WINDOWS";
        $pass_dosbox_x_rev_file = "$line/__WINDOWS__";
    }
    if (defined($pass_dosbox_x_rev_file) && -f $pass_dosbox_x_rev_file ) {
        open(R,"<",$pass_dosbox_x_rev_file) || die;
        # 20180208-004727-cf142387b7108d61666c99f9b8bd7bee5f054284-develop
        # yyyymmdd-hhmmss-commit-----------------------------------branch
        $pass_dosbox_x_rev = <R>;
        chomp $pass_dosbox_x_rev;
        close(R);

        my $x = $pass_dosbox_x_rev;
        if ($x =~ s/^\d+-\d+-//) {
            $x =~ s/\-.*$//g;
            $pass_dosbox_x_url = "https://github.com/joncampbell123/dosbox-x/commit/".$x;
        }
    }

    my $notes_dosbox_x = undef;
    if ( -f "$line/__NOTES__" ) {
        my $nline="",$pline,$res="",$ncount=0;

        open(X,"<","$line/__NOTES__") || die;
        while ($nline = <X>) {
            $pline = $nline;
            chomp $nline;
            $nline =~ s/^[ \t]+//;
            $nline =~ s/[ \t]+$//;
            next if $nline eq "";
            $res .= "\n" if $ncount > 0;
            $res .= "$nline";
            $ncount++;
        }
        close(X);
        $notes_dosbox_x = $res;
    }

    my $pass_dosbox_svn = undef;
    my $pass_dosbox_svn_rev = undef;
    my $pass_dosbox_svn_rev_file = undef;

    die unless !defined($pass_dosbox_svn);
    die unless !defined($pass_dosbox_svn_rev);
    die unless !defined($pass_dosbox_svn_rev_file);

    if ( -f "$line/__PASS_SVN__" ) {
        $tot_svn++;
        $pass_svn++;
        $pass_dosbox_svn = "PASS";
        $pass_dosbox_svn_rev_file = "$line/__PASS_SVN__";
    }
    if ( -f "$line/__FAIL_SVN__" ) {
        $tot_svn++;
        $pass_dosbox_svn = "FAIL";
        $pass_dosbox_svn_rev_file = "$line/__FAIL_SVN__";
    }
    if ( -f "$line/__WINDOWS_SVN__" ) {
        $pass_dosbox_svn = "WINDOWS";
        $pass_dosbox_svn_rev_file = "$line/__WINDOWS_SVN__";
    }
    if (defined($pass_dosbox_svn_rev_file) && -f $pass_dosbox_svn_rev_file ) {
        open(R,"<",$pass_dosbox_svn_rev_file) || die;
        $pass_dosbox_svn_rev = <R>;
        chomp $pass_dosbox_svn_rev;
        close(R);

        my $x = $pass_dosbox_svn_rev;
        $x =~ s/^git=[^ ]+ +//;
        if ($x =~ s/^svn=r//) {
            if ($x =~ m/^\d+ /) {
                $x =~ s/ .*$//g;
                $pass_dosbox_svn_url = "https://sourceforge.net/p/dosbox/code-0/".$x."/";
            }
        }
    }

    my $notes_dosbox_svn = undef;
    if ( -f "$line/__NOTES_SVN__" ) {
        my $nline="",$pline,$res="",$ncount=0;

        open(X,"<","$line/__NOTES_SVN__") || die;
        while ($nline = <X>) {
            $pline = $nline;
            chomp $nline;
            $nline =~ s/^[ \t]+//;
            $nline =~ s/[ \t]+$//;
            next if $nline eq "";
            $res .= "\n" if $ncount > 0;
            $res .= "$nline";
            $ncount++;
        }
        close(X);
        $notes_dosbox_svn = $res;
    }

    if (!(defined($pass_dosbox_x) || defined($pass_dosbox_svn))) {
        # FIXME: need to handle dirs with single quotes
        next if $line =~ m/\'/;

        # skip m4ch directories
        next if $line =~ s/\/m4ch\///;

        # skip unless it has an EXE or COM file
        $path_esc=escape_shell($line);
        $x=`cd $path_esc && ls -- *.exe *.EXE *.com *.COM 2>/dev/null | head -n 1`; chomp $x;
        next if $x eq "";
    }

    # stop going into subdirs
    next if -f "$line/__IGNORE__";

    my $pass_dosbox_xdos = undef;
    my $pass_dosbox_xdos_rev = undef;
    my $pass_dosbox_xdos_url = undef;
    my $pass_dosbox_xdos_rev_file = undef;

    die unless !defined($pass_dosbox_xdos);
    die unless !defined($pass_dosbox_xdos_url);
    die unless !defined($pass_dosbox_xdos_rev);
    die unless !defined($pass_dosbox_xdos_rev_file);

    if ( -f "$line/__PASS_XDOS__" ) {
        $tot_xdos++;
        $pass_xdos++;
        $pass_dosbox_xdos = "PASS";
        $pass_dosbox_xdos_rev_file = "$line/__PASS_XDOS__";
    }
    if ( -f "$line/__FAIL_XDOS__" ) {
        $tot_xdos++;
        $pass_dosbox_xdos = "FAIL";
        $pass_dosbox_xdos_rev_file = "$line/__FAIL_XDOS__";
    }
    if ( -f "$line/__WINDOWS_XDOS__" ) {
        $pass_dosbox_xdos = "WINDOWS";
        $pass_dosbox_xdos_rev_file = "$line/__WINDOWS_XDOS__";
    }
    if (defined($pass_dosbox_xdos_rev_file) && -f $pass_dosbox_xdos_rev_file ) {
        open(R,"<",$pass_dosbox_xdos_rev_file) || die;
        # 20180208-004727-cf142387b7108d61666c99f9b8bd7bee5f054284-develop
        # yyyymmdd-hhmmss-commit-----------------------------------branch
        $pass_dosbox_xdos_rev = <R>;
        chomp $pass_dosbox_xdos_rev;
        close(R);

        my $x = $pass_dosbox_xdos_rev;
        if ($x =~ s/^\d+-\d+-//) {
            $x =~ s/\-.*$//g;
            $pass_dosbox_xdos_url = "https://github.com/joncampbell123/dosbox-x/commit/".$x;
        }
    }

    my $notes_dosbox_xdos = undef;
    if ( -f "$line/__NOTES_XDOS__" ) {
        my $nline="",$pline,$res="",$ncount=0;

        open(X,"<","$line/__NOTES_XDOS__") || die;
        while ($nline = <X>) {
            $pline = $nline;
            chomp $nline;
            $nline =~ s/^[ \t]+//;
            $nline =~ s/[ \t]+$//;
            next if $nline eq "";
            $res .= "\n" if $ncount > 0;
            $res .= "$nline";
            $ncount++;
        }
        close(X);
        $notes_dosbox_xdos = $res;
    }

    my $pass_dosbox_svndos = undef;
    my $pass_dosbox_svndos_rev = undef;
    my $pass_dosbox_svndos_url = undef;
    my $pass_dosbox_svndos_rev_file = undef;

    die unless !defined($pass_dosbox_svndos);
    die unless !defined($pass_dosbox_svndos_url);
    die unless !defined($pass_dosbox_svndos_rev);
    die unless !defined($pass_dosbox_svndos_rev_file);

    if ( -f "$line/__PASS_SVNDOS__" ) {
        $tot_svndos++;
        $pass_svndos++;
        $pass_dosbox_svndos = "PASS";
        $pass_dosbox_svndos_rev_file = "$line/__PASS_SVNDOS__";
    }
    if ( -f "$line/__FAIL_SVNDOS__" ) {
        $tot_svndos++;
        $pass_dosbox_svndos = "FAIL";
        $pass_dosbox_svndos_rev_file = "$line/__FAIL_SVNDOS__";
    }
    if ( -f "$line/__WINDOWS_SVNDOS__" ) {
        $pass_dosbox_svndos = "WINDOWS";
        $pass_dosbox_svndos_rev_file = "$line/__WINDOWS_SVNDOS__";
    }
    if (defined($pass_dosbox_svndos_rev_file) && -f $pass_dosbox_svndos_rev_file ) {
        open(R,"<",$pass_dosbox_svndos_rev_file) || die;
        $pass_dosbox_svndos_rev = <R>;
        chomp $pass_dosbox_svndos_rev;
        close(R);

        my $x = $pass_dosbox_svndos_rev;
        $x =~ s/^git=[^ ]+ +//;
        if ($x =~ s/^svn=r//) {
            if ($x =~ m/^\d+ /) {
                $x =~ s/ .*$//g;
                $pass_dosbox_svndos_url = "https://sourceforge.net/p/dosbox/code-0/".$x."/";
            }
        }
    }

    my $notes_dosbox_svndos = undef;
    if ( -f "$line/__NOTES_SVNDOS__" ) {
        my $nline="",$pline,$res="",$ncount=0;

        open(X,"<","$line/__NOTES_SVNDOS__") || die;
        while ($nline = <X>) {
            $pline = $nline;
            chomp $nline;
            $nline =~ s/^[ \t]+//;
            $nline =~ s/[ \t]+$//;
            next if $nline eq "";
            $res .= "\n" if $ncount > 0;
            $res .= "$nline";
            $ncount++;
        }
        close(X);
        $notes_dosbox_svndos = $res;
    }

    my $pass_dosbox_svnbochs = undef;
    my $pass_dosbox_svnbochs_rev = undef;
    my $pass_dosbox_svnbochs_url = undef;
    my $pass_dosbox_svnbochs_rev_file = undef;

    die unless !defined($pass_dosbox_svnbochs);
    die unless !defined($pass_dosbox_svnbochs_url);
    die unless !defined($pass_dosbox_svnbochs_rev);
    die unless !defined($pass_dosbox_svnbochs_rev_file);

    if ( -f "$line/__PASS_SVNBOCHS__" ) {
        $tot_bochs++;
        $pass_bochs++;
        $pass_dosbox_svnbochs = "PASS";
        $pass_dosbox_svnbochs_rev_file = "$line/__PASS_SVNBOCHS__";
    }
    if ( -f "$line/__FAIL_SVNBOCHS__" ) {
        $tot_bochs++;
        $pass_dosbox_svnbochs = "FAIL";
        $pass_dosbox_svnbochs_rev_file = "$line/__FAIL_SVNBOCHS__";
    }
    if ( -f "$line/__WINDOWS_SVNBOCHS__" ) {
        $pass_dosbox_svnbochs = "WINDOWS";
        $pass_dosbox_svnbochs_rev_file = "$line/__WINDOWS_SVNBOCHS__";
    }
    if (defined($pass_dosbox_svnbochs_rev_file) && -f $pass_dosbox_svnbochs_rev_file ) {
        open(R,"<",$pass_dosbox_svnbochs_rev_file) || die;
        $pass_dosbox_svnbochs_rev = <R>;
        chomp $pass_dosbox_svnbochs_rev;
        close(R);

        my $x = $pass_dosbox_svnbochs_rev;
        $x =~ s/^git=[^ ]+ +//;
        if ($x =~ s/^svn=r//) {
            if ($x =~ m/^\d+ /) {
                $x =~ s/ .*$//g;
                $pass_dosbox_svnbochs_url = "https://sourceforge.net/p/bochs/code/".$x."/";
            }
        }
    }

    my $notes_dosbox_svnbochs = undef;
    if ( -f "$line/__NOTES_SVNBOCHS__" ) {
        my $nline="",$pline,$res="",$ncount=0;

        open(X,"<","$line/__NOTES_SVNBOCHS__") || die;
        while ($nline = <X>) {
            $pline = $nline;
            chomp $nline;
            $nline =~ s/^[ \t]+//;
            $nline =~ s/[ \t]+$//;
            next if $nline eq "";
            $res .= "\n" if $ncount > 0;
            $res .= "$nline";
            $ncount++;
        }
        close(X);
        $notes_dosbox_svnbochs = $res;
    }

    my $pass_dosbox_qemu = undef;
    my $pass_dosbox_qemu_rev = undef;
    my $pass_dosbox_qemu_url = undef;
    my $pass_dosbox_qemu_rev_file = undef;

    die unless !defined($pass_dosbox_qemu);
    die unless !defined($pass_dosbox_qemu_url);
    die unless !defined($pass_dosbox_qemu_rev);
    die unless !defined($pass_dosbox_qemu_rev_file);

    if ( -f "$line/__PASS_QEMU__" ) {
        $tot_qemu++;
        $pass_qemu++;
        $pass_dosbox_qemu = "PASS";
        $pass_dosbox_qemu_rev_file = "$line/__PASS_QEMU__";
    }
    if ( -f "$line/__FAIL_QEMU__" ) {
        $tot_qemu++;
        $pass_dosbox_qemu = "FAIL";
        $pass_dosbox_qemu_rev_file = "$line/__FAIL_QEMU__";
    }
    if ( -f "$line/__WINDOWS_QEMU__" ) {
        $pass_dosbox_qemu = "WINDOWS";
        $pass_dosbox_qemu_rev_file = "$line/__WINDOWS_QEMU__";
    }
    if (defined($pass_dosbox_qemu_rev_file) && -f $pass_dosbox_qemu_rev_file ) {
        open(R,"<",$pass_dosbox_qemu_rev_file) || die;
        $pass_dosbox_qemu_rev = <R>;
        chomp $pass_dosbox_qemu_rev;
        close(R);

        my $x = $pass_dosbox_qemu_rev;
        $x =~ s/^git=[^ ]+ +//;
        if ($x =~ s/^svn=r//) {
            if ($x =~ m/^\d+ /) {
                $x =~ s/ .*$//g;
                $pass_dosbox_qemu_url = "https://sourceforge.net/p/bochs/code/".$x."/";
            }
        }
    }

    my $url = undef;
    my $vcard = "";
    my $pc98 = 0;

    if (open(URL,"$line/dosbox.conf")) {
        foreach my $uline (<URL>) {
            my $name,$value,$i;
            chomp $uline;

            $i = index($uline,'=');
            next if $i <= 0;

            $name = substr($uline,0,$i);
            $value = substr($uline,$i+1);

            if ($name eq "machine") {
                if ($value eq "pc98") {
                    $pc98 = 1;
                }
                else {
                    $vcard = $value;
                    $vcard = "vga" if $vcard eq "vgaonly";
                }
            }
        }
    }

    if (open(URL,"$line/__DOWNLOAD__")) {
        foreach my $uline (<URL>) {
            my $name,$value,$i;
            chomp $uline;

            $i = index($uline,'=');
            next if $i <= 0;

            $name = substr($uline,0,$i);
            $value = substr($uline,$i+1);

            if ($name eq "url") {
                $url = $value;
            }
        }
    }

    if ($pc98) {
        $tot_pc98++;
    }

    my $notes_dosbox_qemu = undef;
    if ( -f "$line/__NOTES_QEMU__" ) {
        my $nline="",$pline,$res="",$ncount=0;

        open(X,"<","$line/__NOTES_QEMU__") || die;
        while ($nline = <X>) {
            $pline = $nline;
            chomp $nline;
            $nline =~ s/^[ \t]+//;
            $nline =~ s/[ \t]+$//;
            next if $nline eq "";
            $res .= "\n" if $ncount > 0;
            $res .= "$nline";
            $ncount++;
        }
        close(X);
        $notes_dosbox_qemu = $res;
    }

    $count++;
    if ($count >= 24) {
        $count = 0;

        print H "</tbody>\n";

        print H "<thead class=\"testing_header\">\n";
        print H "<tr>\n";
        print H "<td style=\"min-width: 6em; text-align: center;\">DOSBox-X</td>";
        print H "<td style=\"min-width: 6em; text-align: center;\">DOSBox-SVN</td>";
        print H "<td style=\"min-width: 6em; text-align: center;\">DOSBox-X-DOS</td>";
        print H "<td style=\"min-width: 8em; text-align: center;\">DOSBox-SVN-DOS</td>";
        print H "<td style=\"min-width: 6em; text-align: center;\">Bochs-SVN</td>";
        print H "<td style=\"min-width: 4em; text-align: center;\">QEMU</td>";
        print H "<td>Demo</td>";
        print H "</tr>\n";
        print H "</thead>\n";

        print H "<tbody>\n";
    }

    print H "<tr>";

    if (defined($pass_dosbox_x)) {
        if (defined($pass_dosbox_x_url) && $pass_dosbox_x_url ne "") {
            print H "<td class=\"passfail_$pass_dosbox_x\"><a target=\"_blank\" href=\"$pass_dosbox_x_url\">$pass_dosbox_x</a></td>";
        }
        else {
            print H "<td class=\"passfail_$pass_dosbox_x\">$pass_dosbox_x</td>";
        }
    }
    else {
        print H "<td class=\"passfail_NA\">untested</td>";
    }

    if (defined($pass_dosbox_svn)) {
        if (defined($pass_dosbox_svn_url) && $pass_dosbox_svn_url ne "") {
            print H "<td class=\"passfail_$pass_dosbox_svn\"><a target=\"_blank\" href=\"$pass_dosbox_svn_url\">$pass_dosbox_svn</a></td>";
        }
        else {
            print H "<td class=\"passfail_$pass_dosbox_svn\">$pass_dosbox_svn</td>";
        }
    }
    elsif ($pc98) { # SVN cannot run PC-98 games
        print H "<td class=\"passfail_NA\">N/A</td>";
    }
    else {
        print H "<td class=\"passfail_NA\">---</td>";
    }

    if (defined($pass_dosbox_xdos)) {
        if (defined($pass_dosbox_xdos_url) && $pass_dosbox_xdos_url ne "") {
            print H "<td class=\"passfail_$pass_dosbox_xdos\"><a target=\"_blank\" href=\"$pass_dosbox_xdos_url\">$pass_dosbox_xdos</a></td>";
        }
        else {
            print H "<td class=\"passfail_$pass_dosbox_xdos\">$pass_dosbox_xdos</td>";
        }
    }
    else {
        print H "<td class=\"passfail_NA\">---</td>";
    }

    if (defined($pass_dosbox_svndos)) {
        if (defined($pass_dosbox_svndos_url) && $pass_dosbox_svndos_url ne "") {
            print H "<td class=\"passfail_$pass_dosbox_svndos\"><a target=\"_blank\" href=\"$pass_dosbox_svndos_url\">$pass_dosbox_svndos</a></td>";
        }
        else {
            print H "<td class=\"passfail_$pass_dosbox_svndos\">$pass_dosbox_svndos</td>";
        }
    }
    elsif ($pc98) { # SVN cannot run PC-98 games
        print H "<td class=\"passfail_NA\">N/A</td>";
    }
    else {
        print H "<td class=\"passfail_NA\">---</td>";
    }

    if (defined($pass_dosbox_svnbochs)) {
        if (defined($pass_dosbox_svnbochs_url) && $pass_dosbox_svnbochs_url ne "") {
            print H "<td class=\"passfail_$pass_dosbox_svnbochs\"><a target=\"_blank\" href=\"$pass_dosbox_svnbochs_url\">$pass_dosbox_svnbochs</a></td>";
        }
        else {
            print H "<td class=\"passfail_$pass_dosbox_svnbochs\">$pass_dosbox_svnbochs</td>";
        }
    }
    elsif ($pc98) { # Bochs cannot run PC-98 games
        print H "<td class=\"passfail_NA\">N/A</td>";
    }
    else {
        print H "<td class=\"passfail_NA\">---</td>";
    }

    if (defined($pass_dosbox_qemu)) {
        if (defined($pass_dosbox_qemu_url) && $pass_dosbox_qemu_url ne "") {
            print H "<td class=\"passfail_$pass_dosbox_qemu\"><a target=\"_blank\" href=\"$pass_dosbox_qemu_url\">$pass_dosbox_qemu</a></td>";
        }
        else {
            print H "<td class=\"passfail_$pass_dosbox_qemu\">$pass_dosbox_qemu</td>";
        }
    }
    elsif ($pc98) { # QEMU cannot run PC-98 games (though there is a patch)
        print H "<td class=\"passfail_NA\">N/A</td>";
    }
    else {
        print H "<td class=\"passfail_NA\">---</td>";
    }

    my $more = "<br>";

    $comb = "";
    $combnotes = "";

    if (defined($symlink_to)) {
        $x = $symlink_to;
        $x =~ s/^(\.\.\/)+//g;
        $x =~ s/^(\.\/)+//g;
        $x =~ s/^unpacked\///;
        $x =~ s/^ftp\.scene\.org\///;
        $x =~ s/^pub\///;
        $more .= "<pre>* This is a known duplicate of $x</pre>";
    }

    if ($comb ne "NO" && defined($notes_dosbox_x) && $notes_dosbox_x ne "") {
        if ($comb eq "" || $combnotes eq $notes_dosbox_x) {
            $comb .= " &amp; " if $comb ne "";
            $comb .= "DOSBox-X";
            $combnotes = $notes_dosbox_x;
        }
        else {
            $comb = "NO";
        }
    }

    if ($comb ne "NO" && defined($notes_dosbox_svn) && $notes_dosbox_svn ne "") {
        if ($comb eq "" || $combnotes eq $notes_dosbox_svn) {
            $comb .= " &amp; " if $comb ne "";
            $comb .= "DOSBox-SVN";
            $combnotes = $notes_dosbox_svn;
        }
        else {
            $comb = "NO";
        }
    }

    if ($comb ne "NO" && defined($notes_dosbox_xdos) && $notes_dosbox_xdos ne "") {
        if ($comb eq "" || $combnotes eq $notes_dosbox_xdos) {
            $comb .= " &amp; " if $comb ne "";
            $comb .= "DOSBox-X-DOS";
            $combnotes = $notes_dosbox_xdos;
        }
        else {
            $comb = "NO";
        }
    }

    if ($comb ne "NO" && defined($notes_dosbox_svndos) && $notes_dosbox_svndos ne "") {
        if ($comb eq "" || $combnotes eq $notes_dosbox_svndos) {
            $comb .= " &amp; " if $comb ne "";
            $comb .= "DOSBox-SVN-DOS";
            $combnotes = $notes_dosbox_svndos;
        }
        else {
            $comb = "NO";
        }
    }

    if ($comb ne "NO" && defined($notes_dosbox_svnbochs) && $notes_dosbox_svnbochs ne "") {
        if ($comb eq "" || $combnotes eq $notes_dosbox_svnbochs) {
            $comb .= " &amp; " if $comb ne "";
            $comb .= "Bochs-SVN";
            $combnotes = $notes_dosbox_svnbochs;
        }
        else {
            $comb = "NO";
        }
    }
 
    if ($comb ne "NO" && defined($notes_dosbox_qemu) && $notes_dosbox_qemu ne "") {
        if ($comb eq "" || $combnotes eq $notes_dosbox_qemu) {
            $comb .= " &amp; " if $comb ne "";
            $comb .= "QEMU";
            $combnotes = $notes_dosbox_qemu;
        }
        else {
            $comb = "NO";
        }
    }
 
    if ($comb eq "" || $comb eq "NO") {
        if (defined($notes_dosbox_x) && $notes_dosbox_x ne "") {
            $more .= "<br>";
            $more .= "DOSBox-X NOTES: <pre>$notes_dosbox_x</pre>";
        }

        if (defined($notes_dosbox_svn) && $notes_dosbox_svn ne "") {
            $more .= "<br>";
            $more .= "DOSBox-SVN NOTES: <pre>$notes_dosbox_svn</pre>";
        }

        if (defined($notes_dosbox_xdos) && $notes_dosbox_xdos ne "") {
            $more .= "<br>";
            $more .= "DOSBox-X-DOS NOTES: <pre>$notes_dosbox_xdos</pre>";
        }

        if (defined($notes_dosbox_svndos) && $notes_dosbox_svndos ne "") {
            $more .= "<br>";
            $more .= "DOSBox-SVN-DOS NOTES: <pre>$notes_dosbox_svndos</pre>";
        }

        if (defined($notes_dosbox_svnbochs) && $notes_dosbox_svnbochs ne "") {
            $more .= "<br>";
            $more .= "Bochs-SVN NOTES: <pre>$notes_dosbox_svnbochs</pre>";
        }

        if (defined($notes_dosbox_qemu) && $notes_dosbox_qemu ne "") {
            $more .= "<br>";
            $more .= "QEMU NOTES: <pre>$notes_dosbox_qemu</pre>";
        }
    }
    else {
        $more .= "<br>";
        $more .= "$comb NOTES: <pre>$combnotes</pre>";
    }

    if ($pc98) {
        $disp_line .= " <sup style=\"color: rgb(0,63,0); font-size: 60%;\">NEC PC-98</sup>";
    }
    else {
        $disp_line .= " <sup style=\"color: rgb(0,0,63); font-size: 60%;\">IBM PC/XT/AT";
        if ($vcard ne "") {
            $disp_line .= " ".uc($vcard);
        }
        $disp_line .= "</sup>";
    }

    if ($url ne "") {
        print H "<td>$disp_line<br><a href=\"$url\">[Download]</a>$more</td>";
    }
    else {
        print H "<td>$disp_line$more</td>";
    }

    print H "</tr>\n";

    if (!($pass_dosbox_x eq "WINDOWS" || $pass_dosbox_svn eq "WINDOWS")) {
        $totalcount++;
    }
}
close(S);

print H "</tbody>\n";

print H "<thead class=\"testing_header\">\n";
print H "<tr>\n";
print H "<td style=\"min-width: 6em; text-align: center;\">DOSBox-X</td>";
print H "<td style=\"min-width: 6em; text-align: center;\">DOSBox-SVN</td>";
print H "<td style=\"min-width: 6em; text-align: center;\">DOSBox-X-DOS</td>";
print H "<td style=\"min-width: 8em; text-align: center;\">DOSBox-SVN-DOS</td>";
print H "<td style=\"min-width: 6em; text-align: center;\">Bochs-SVN</td>";
print H "<td style=\"min-width: 4em; text-align: center;\">QEMU</td>";
print H "<td>Demo</td>";
print H "</tr>\n";
print H "</thead>\n";

print H "<tbody>\n";

sub makestat($$$) {
    my $totalcount = shift @_;
    my $total = shift @_;
    my $pass = shift @_;

    return "--" unless defined($total) && defined($pass) && $total > 0;

    $percent = ($pass * 100) / $total;
    $percent = int($percent * 100) / 100;

    $coverage = ($total * 100) / $totalcount;
    $coverage = int($coverage * 100) / 100;

    return sprintf("TOTAL:<br>%u<br><br>".
                   "TESTED:<br>%u<br><br>".
                   "COVERAGE:<br>%%%.2f<br><br>".
                   "PASS:<br>%u<br><br>".
                   "FAIL:<br>%u<br><br>".
                   "PASSED:<br>%%%.2f",
                   $totalcount,
                   $total,
                   $coverage,
                   $pass,
                   $total-$pass,
                   $percent);
}

print H "<tr>\n";
print H "<td style=\"min-width: 6em; text-align: center;\">".makestat($totalcount          ,$tot_x,$pass_x)."</td>";
print H "<td style=\"min-width: 6em; text-align: center;\">".makestat($totalcount-$tot_pc98,$tot_svn,$pass_svn)."</td>";
print H "<td style=\"min-width: 6em; text-align: center;\">".makestat($totalcount          ,$tot_xdos,$pass_xdos)."</td>";
print H "<td style=\"min-width: 8em; text-align: center;\">".makestat($totalcount-$tot_pc98,$tot_svndos,$pass_svndos)."</td>";
print H "<td style=\"min-width: 6em; text-align: center;\">".makestat($totalcount-$tot_pc98,$tot_bochs,$pass_bochs)."</td>";
print H "<td style=\"min-width: 4em; text-align: center;\">".makestat($totalcount-$tot_pc98,$tot_qemu,$pass_qemu)."</td>";
print H "<td>TEST RESULTS</td>";
print H "</tr>\n";

print H "</tbody>\n";
print H "</table>\n";

print H "</body>\n";
print H "</html>\n";

close(H);

