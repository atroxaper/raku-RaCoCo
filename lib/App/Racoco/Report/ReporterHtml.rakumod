unit module App::Racoco::Report::ReporterHtml;

use App::Racoco::Report::Report;
use App::Racoco::Report::Reporter;
use App::Racoco::Report::ReporterBasic;
use App::Racoco::Paths;
use App::Racoco::ModuleNames;
use App::Racoco::ProjectName;

class ReporterHtml does Reporter is export {
  has ReporterBasic $!reporter is built;
  has IO::Path $!lib;
  has Bool $.color-blind is rw;

  method make-from-data(:%coverable-lines, :%covered-lines --> Reporter) {
    self.bless(reporter =>
      ReporterBasic.make-from-data(:%coverable-lines, :%covered-lines));
  }

  method read(IO::Path :$lib --> Reporter) {
    with ReporterBasic.read(:$lib) {
      self.bless(reporter => $_)
    } else {
      Nil
    }
  }

  method report(--> Report) {
    $!reporter.report
  }

  method write(IO::Path :$lib --> IO::Path) {
    $!lib = $lib;
    $!reporter.write(:$lib);
    my %module-links = self!write-module-pages();
    my $result = self!write-main-page(%module-links);
    self!write-main-page-url();
    $result
  }

  method !write-module-pages(--> Associative) {
    my $template = %?RESOURCES<report-file.html>.slurp;
    $!reporter.report.all-data.map(-> $data {
      $data.file-name => self!write-module-page($data, $template)
    }).Map
  }

  method !write-main-page(%module-links --> IO::Path) {
    my $path = report-html-path(:$!lib);
    my $template = %?RESOURCES<report.html>.slurp;

    $template .= subst('%%report-lines%%', self!code-main-page-content(%module-links));
    $template .= subst('%%project-name%%', project-name(:$!lib), :g);

    $path.spurt: $template;
    $path
  }

  method !write-main-page-url() {
    say "Visualisation: file://", report-html-path(:$!lib).Str
  }

  method !write-module-page(FileReportData $data, Str $template is copy--> Str) {
    my $path = report-html-data-path(:$!lib)
      .add(self!module-page-name($data.file-name));

    $template .= subst('%%pre%%', self!code-module-content($data));
    $template .= subst('%%module-name%%', module-name(:path($data.file-name)), :g);
    $template .= subst('%%module-coverage%%', $data.percent);
    $template .= subst('/*color-blind', '') if $!color-blind;

    $path.spurt: $template;
    $path.Str.substr(report-html-data-path(:$!lib).Str.chars + '/'.chars)
  }

  method !module-page-name(Str $file-name --> Str) {
    module-parts(path => $file-name.IO).join('-') ~ '.html'
  }

  method !code-main-page-content(%module-links --> Str) {
    $!reporter.report.all-data.map(-> $data {
      self!code-main-page-module-content($data, %module-links);
    }).join("\n")
  }

  method !code-main-page-module-content(FileReportData $data, %module-links --> Str) {
    my $template = q:to/END/;
    <tr class="report">
    <td><a href="./report-data/%%link%%">%%module-name%%</a></td>
    <td>%%percent%%</td>
    <td>
    <span class="progress-bar">
    <span class="progress-bar-fill" style="width: %%percent%%%;"></span>
    </span>
    </td>
    <td class="total">%%coverable%%</td>
    <td class="covered">%%covered%%</td>
    </tr>
    END
    $template .= subst('%%link%%', %module-links{$data.file-name});
    $template .= subst('%%module-name%%', module-name(path => $data.file-name.IO));
    $template .= subst('%%percent%%', $data.percent);
    $template .= subst('%%percent%%', $data.percent);
    $template .= subst('%%coverable%%', $data.coverable);
    $template .= subst('%%covered%%', $data.covered);
    $template.lines.join('')
  }

  method !code-module-content(FileReportData $data --> Str) {
    $!lib.add($data.file-name).lines.kv.map(-> $i, $line {
      my $color = self!get-color($data, $i + 1);
      my $esc = self!esc-line($line);
      sprintf('<span class="coverage-%s">%s</span>', $color, $esc)
    }).join("\n")
  }

  method !get-color($data, $line) {
    ($data.color(:$line) // 'no').lc;
  }

  method !esc-line($line) {
    $line.trans(['<', '>', '&', '"'] => [ '&lt;', '&gt;', '&amp;', '&quot;' ])
  }
}