use App::Racoco::Report::Reporter;

unit class App::Racoco::Report::ReporterHtml does Reporter is export;

use App::Racoco::Paths;
use App::Racoco::ModuleNames;
use App::Racoco::ProjectName;

has IO::Path $!lib;
has Bool $.color-blind is rw;

method do(:$lib, :$data, :$properties) {
  $!lib = $lib;
  my %module-links = self!write-module-pages($data);
  self!write-main-page($data, %module-links);
  self!write-main-page-url();
}

method !write-module-pages($data --> Associative) {
  my $template = %?RESOURCES<report-file.html>.slurp;
  $data.get-all-parts.map(-> $part {
    $part.file-name => self!write-module-page($part, $template)
  }).Map
}

method !write-main-page($data, %module-links) {
  my $path = report-html-path(:$!lib);
  my $template = %?RESOURCES<report.html>.slurp;

  $template .= subst('%%report-lines%%', self!code-main-page-content($data, %module-links));
  $template .= subst('%%project-name%%', project-name(:$!lib), :g);

  $path.spurt: $template;
}

method !write-main-page-url() {
  say "Visualisation: file://", report-html-path(:$!lib).Str
}

method !write-module-page($part, Str $template is copy --> Str) {
  my $path = report-html-data-path(:$!lib)
    .add(self!module-page-name($part.file-name));

  $template .= subst('%%pre%%', self!code-module-content($part));
  $template .= subst('%%module-name%%', module-name(:path($part.file-name)), :g);
  $template .= subst('%%module-coverage%%', $part.percent);
  $template .= subst('/*color-blind', '') if $!color-blind;

  $path.spurt: $template;
  $path.Str.substr(report-html-data-path(:$!lib).Str.chars + '/'.chars)
}

method !module-page-name(Str $file-name --> Str) {
  module-parts(path => $file-name.IO).join('-') ~ '.html'
}

method !code-main-page-content($data, %module-links --> Str) {
  $data.get-all-parts.map(-> $part {
    self!code-main-page-module-content($part, %module-links);
  }).join("\n")
}

method !code-main-page-module-content($part, %module-links --> Str) {
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
  $template .= subst('%%link%%', %module-links{$part.file-name});
  $template .= subst('%%module-name%%', module-name(path => $part.file-name.IO));
  $template .= subst('%%percent%%', $part.percent);
  $template .= subst('%%percent%%', $part.percent);
  $template .= subst('%%coverable%%', $part.coverable-amount);
  $template .= subst('%%covered%%', $part.covered-amount);
  $template.lines.join('')
}

method !code-module-content($part --> Str) {
  $!lib.add($part.file-name).lines.kv.map(-> $i, $line {
    my $color = self!get-color($part, $i + 1);
    my $esc = self!esc-line($line);
    sprintf('<span class="coverage-%s">%s</span>', $color, $esc)
  }).join("\n")
}

method !get-color($part, $line) {
  $part.color-of(:$line).lc;
}

method !esc-line($line) {
  $line.trans(['<', '>', '&', '"'] => [ '&lt;', '&gt;', '&amp;', '&quot;' ])
}