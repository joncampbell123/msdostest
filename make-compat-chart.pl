#!/usr/bin/perl
my $line;

open(H,">compat-chart.html") || die;

print H "<html>\n";
print H "<head>\n";
print H "<title>Demoscene compat testing chart</title>\n";
print H "<style>\n";
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

print H "DOSBox demoscene compat testing chart<br>\n";
print H "Ref: <a href=\"ftp://ftp.scene.org\">ftp://ftp.scene.org</a><br>\n";
print H "Demoscene testing repository: <a target=\"_blank\" href=\"https://github.com/joncampbell123/demotest\">https://github.com/joncampbell123/demotest</a><br>\n";

print H "<br>\n";

print H "DOSBox-X refers to the <a target=\"_blank\" href=\"http://dosbox-x.com/\">DOSBox-X project</a><br>\n";
print H "DOSBox-SVN refers to the <a target=\"_blank\" href=\"https://www.dosbox.com/\">DOSBox project</a><br>\n";
print H "<br>\n";

print H "Rules regarding PASS or FAIL:<br>\n";
print H "- If a demo crashes, faults, or shows behavior that suggests a problem, that is a FAIL.<br>\n";
print H "- Known faulty behavior in the demo itself doesn't count as failure. Future development may offer off-by-default hacks or workarounds in the emulator for the problem.<br>\n";
print H "- Known faulty behavior that occurs on real hardware doesn't count as failure, because it means DOSBox is emulating real hardware accurately and the demo is at fault.<br>\n";
print H "- Issues that are DOSBox-SVN's fault, that the DOSBox SVN developers have expressed an unwillingness to fix or accept patches to fix, do not count as failure.<br>\n";
print H "<br>\n";

print H "Common problems with DOSBox SVN so far:<br>\n";
print H "- Lack of support for &quot;goldplay&quot; Sound Blaster playback. Audio is rendered &quot;muffled&quot; in DOSBox SVN.<br>\n";
print H "- LPT DAC output doesn't work. However code explicitly written for the Disney Sound Source works.<br>\n";
print H "- PC speaker emulation on/off and frequency changes are limited to 1ms precision. This affects some demos as well as old Apogee titles like Duke Nukum.<br>\n";
print H "- Some demos rely on INT 16h AH=1 undefined behavior regarding ZF flag (standard only describes CF flag), which so far has been confirmed on at least one 386 system and may occur in other old systems.<br>\n";
print H "<br>\n";

print H "Common problems to both DOSBox-X and DOSBox-SVN:<br>\n";
print H "- Having UMB or EMS enabled can cause crashiness in some demos.<br>\n";
print H "- Some demos require XMS to be enabled, will call to a NULL pointer otherwise.<br>\n";
print H "- Some demos will crash or malfunction if loaded too low (below 64KB) in memory. Try loadfix or the minimum mcb segment option.<br>\n";
print H "<br>\n";

print H "Problems that do NOT count as failures against DOSBox SVN, because they are bugs in the demo itself:<br>\n";
print H "- Audio halting or interrupt problems with GUS or SB related to a failure to unmask the IRQ (democoder laziness, NOT SVN's fault).<br>\n";
print H "- Hangs related to undefined or reserved bits in VGA emulation that the demo really ought to ignore.<br>\n";
print H "<br>\n";

print H "<table cellpadding=0 cellspacing=0>\n";
print H "<thead class=\"testing_header\">\n";
print H "<tr>\n";
print H "<td style=\"min-width: 6em; text-align: center;\">DOSBox-X</td>";
print H "<td style=\"min-width: 6em; text-align: center;\">DOSBox-SVN</td>";
print H "<td>Demo</td>";
print H "</tr>\n";
print H "</thead>\n";

print H "<tbody>\n";

$count = 0;
open(S,"find -type d | sort |") || die;
while ($line = <S>) {
    chomp $line;

    $line =~ s/^\.\///;
    $disp_line = $line;
    next unless $disp_line =~ s/^unpacked\///;

    my $pass_dosbox_x = undef;
    my $pass_dosbox_x_rev = undef;
    my $pass_dosbox_x_url = undef;
    my $pass_dosbox_x_rev_file = undef;

    die unless !defined($pass_dosbox_x);
    die unless !defined($pass_dosbox_x_url);
    die unless !defined($pass_dosbox_x_rev);
    die unless !defined($pass_dosbox_x_rev_file);

    if ( -f "$line/__PASS__" ) {
        $pass_dosbox_x = "PASS";
        $pass_dosbox_x_rev_file = "$line/__PASS__";
    }
    if ( -f "$line/__FAIL__" ) {
        $pass_dosbox_x = "FAIL";
        $pass_dosbox_x_rev_file = "$line/__FAIL__";
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
        $pass_dosbox_svn = "PASS";
        $pass_dosbox_svn_rev_file = "$line/__PASS_SVN__";
    }
    if ( -f "$line/__FAIL_SVN__" ) {
        $pass_dosbox_svn = "FAIL";
        $pass_dosbox_svn_rev_file = "$line/__FAIL_SVN__";
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

    next unless defined($pass_dosbox_x) || defined($pass_dosbox_svn);

    $count++;
    if ($count >= 24) {
        $count = 0;

        print H "</tbody>\n";

        print H "<thead class=\"testing_header\">\n";
        print H "<tr>\n";
        print H "<td style=\"min-width: 6em; text-align: center;\">DOSBox-X</td>";
        print H "<td style=\"min-width: 6em; text-align: center;\">DOSBox-SVN</td>";
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
        print H "<td class=\"passfail_NA\">---</td>";
    }

    if (defined($pass_dosbox_svn)) {
        if (defined($pass_dosbox_svn_url) && $pass_dosbox_svn_url ne "") {
            print H "<td class=\"passfail_$pass_dosbox_svn\"><a target=\"_blank\" href=\"$pass_dosbox_svn_url\">$pass_dosbox_svn</a></td>";
        }
        else {
            print H "<td class=\"passfail_$pass_dosbox_svn\">$pass_dosbox_svn</td>";
        }
    }
    else {
        print H "<td class=\"passfail_NA\">---</td>";
    }

    my $more = "<br>";

    if (defined($notes_dosbox_x) && $notes_dosbox_x ne "" &&
        defined($notes_dosbox_svn) && $notes_dosbox_svn ne "" &&
        $notes_dosbox_x eq $notes_dosbox_svn) {
        $more .= "<br>";
        $more .= "DOSBox-X &amp; DOSBox-SVN NOTES: <pre>$notes_dosbox_x</pre>";
    }
    else {
        if (defined($notes_dosbox_x) && $notes_dosbox_x ne "") {
            $more .= "<br>";
            $more .= "DOSBox-X NOTES: <pre>$notes_dosbox_x</pre>";
        }

        if (defined($notes_dosbox_svn) && $notes_dosbox_svn ne "") {
            $more .= "<br>";
            $more .= "DOSBox-SVN NOTES: <pre>$notes_dosbox_svn</pre>";
        }
    }

    if ($disp_line =~ s/^ftp\.scene\.org\///) {
        $disp_line =~ s/^pub\///;
        print H "<td><a href=\"http://files.scene.org/get/$disp_line\">$disp_line</a>$more</td>";
    }
    else {
        print H "<td>$disp_line$more</td>";
    }

    print H "</tr>\n";
}
close(S);

print H "</tbody>\n";
print H "</table>\n";

print H "</body>\n";
print H "</html>\n";

close(H);

