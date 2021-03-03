unit module Racoco::Report;
use Racoco::Paths;

enum COLOR is export <GREEN RED PURPLE>;

sub percent-round($n) {
  ($n * 10).Int / 10;
}

class ReportFile is export {
  has Str $.file;
  has Set $.green;
  has Set $.red;
  has Set $.purple;

  submethod BUILD(:$!file, Set() :$!green, Set() :$!red, Set() :$!purple) {}

  method percent() {
    my $covered = $!green.elems + $!purple.elems;
    my $possible = $!green.elems + $!red.elems;
    return 100 if $possible == 0;
    min(100, percent-round(($covered / $possible) * 100));
  }

  method color(Int $n) {
    return GREEN if $!green{$n};
    return RED if $!red{$n};
    return PURPLE if $!purple{$n};
    Nil
  }
}

class Report is export {
  has %!files;

  method new(:@files) {
    self.bless(files => @files.map({ .file => $_ }).Hash)
  }

  submethod BUILD(:%!files) { }

  method percent() {
    return 100 if %!files.elems == 0;
    percent-round(%!files.values.map(*.percent).sum / %!files.elems);
  }

  method get($file) {
    %!files{$file}
  }

  method files() {
    %!files.values.sort(*.file).List
  }
}

role Reporter {
  method from-data(:%possible-lines, :%covered-lines --> Reporter) { ... }
  method write(:$lib --> IO::Path) { ... }
}

class BaseReporter does Reporter is export {
  has Report $.report;

  method from-data(:%possible-lines, :%covered-lines --> Reporter) {
    my @files = %possible-lines.map(-> $p {
      my $covered = (%covered-lines{$p.key} // ()).Set;
      my $possible = $p.value.Set;
      my $green = $possible ∩ $covered;
      my $red = $possible ∖ $covered;
      my $purple = $covered ∖ $possible;
      ReportFile.new(:file($p.key), :$green, :$red, :$purple)
    }).List;

    self.bless(report => Report.new(:@files));
  }

  method write(:$lib --> IO::Path) {
    return Nil unless $lib.e;
    my $path = $lib.parent.add(DOT-RACOCO).add(REPORT-TXT);
    my $h = $path.open(:w);
    LEAVE { .close with $h }
    $h.say($!report.percent(), '%');
    $!report.files().map(-> $f {
      $h.say($f.file);
      $h.say($f.percent, '%');
      $h.say('green ', "{$f.green.keys.sort.List}") if $f.green;
      $h.say('red ', "{$f.red.keys.sort.List}") if $f.red;
      $h.say('purple ', "{$f.purple.keys.sort.List}") if $f.purple;
    });
    $path
  }

  class HtmlReporter does Reporter is export {
    has BaseReporter $.base;
    my $report-line = '<tr class="report"><td>%%module-name%%</td><td>%%percent%%</td><td><div class="progress-bar"><span class="progress-bar-fill" style="width: %%progress%%%;"></span></div></td><td class="total">%%total%%</td><td class="covered">%%coveted%%</td></tr>';

    method from-data(:%possible-lines, :%covered-lines --> Reporter) {
      self.bless(base =>
        BaseReporter.from-data(:%possible-lines, :%covered-lines));
    }

    method write(:$lib --> IO::Path) {
      return Nil unless $lib.e;
      $!base.write(:$lib);
      my $racoco = $lib.parent.add(DOT-RACOCO);
      my $report-html = $racoco.add(REPORT-HTML);
      my $modules = $racoco.add(REPORT-MODULES);
      $modules.mkdir;
      my $html = %?RESOURCES<report.html>.slurp;
      my $file-html = %?RESOURCES<report-file.html>.slurp;
      $html .= subst('%%project-name%%', $lib.absolute.IO.parent.basename, :g);
      my $report = $!base.report;
      my @report-lines;
      for $report.files -> $file {
        my $line = $report-line;
        $line .= subst('%%module-name%%', self!get-module-name($file.file));
        $line .= subst('%%percent%%', $file.percent);
        $line .= subst('%%progress%%', $file.percent.round);
        $line .= subst('%%total%%', $file.green.elems + $file.red.elems);
        $line .= subst('%%coveted%%', $file.green.elems + $file.purple.elems);
        @report-lines.push: $line;

        my $content = $file-html
          .subst('%%module-name%%', self!get-module-name($file.file), :g)
          .subst('%%module-coverage%%', $file.percent)
          .subst('%%pre%%', self!write-file($lib, $file));

        $modules.add(self!get-file-for-module($file.file)).spurt($content);
      }
      $html .= subst('%%report-lines%%', @report-lines.join("\n"));
      $report-html.spurt($html);
      $report-html
    }

    method !write-file($lib, $file) {
      my @pre;
      for $lib.add($file.file).lines.kv -> $i, $line {
        @pre.push: sprintf('<span class="coverage-%s">%s</span>', self!get-span-class($file, $i), $line);
      }
      return @pre.join("\n");
    }

    method !get-span-class($file, $i) {
      return 'red' if $file.color($i + 1) === RED;
      return 'green' if $file.color($i + 1) === GREEN;
      return 'purple' if $file.color($i + 1) === PURPLE;
      return 'no';
    }

    method !get-module-name($path) {
      my @parts = self!get-module-parts($path);
      return @parts.join('::');
    }

    method !get-module-parts(IO() $path is copy) {
      my @parts;
      $path .= extension('');
      while $path ne '.' {
        @parts.push: $path.basename;
        $path .= parent;
      }
      @parts.reverse
    }

    method !get-file-for-module($path) {
      my @parts = self!get-module-parts($path);
      @parts.map(*.lc).join('-') ~ '.html';
    }
  }

}