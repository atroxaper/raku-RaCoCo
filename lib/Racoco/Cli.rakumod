use Racoco::Annotation;
use Racoco::PrecompFile;
use Racoco::HitCollector;
use Racoco::UtilExtProc;
use Racoco::Paths;
use Racoco::Report;

sub MAIN() is export {

  my $lib = 'lib'.IO;
  $lib.parent.add(DOT-RACOCO).add(DOT-PRECOMP).mkdir;
  my $exec = 'prove6';
  my $moar = 'moar';
  my $raku = 'raku';

  my $proc = RunProc.new;
  my $hit-collector = HitCollector.new(:$exec, :$lib, :$proc);
  my $provider = ProviderReal.new(:$proc, :$lib, :$raku);
  my $index = IndexFile.new(:$lib);
  my $dumper = DumperReal.new(:$proc, :$moar);
  my $hashcodeGetter = HashcodeGetterReal.new;
  my $calculator = Calculator.new(:$provider, :$index, :$dumper, :$hashcodeGetter);
  my $annotation-collector = AnnotationCollector.new(:$lib, :$calculator);

  my %covered-lines = $hit-collector.get();
  my %possible-lines = $annotation-collector.get();
  HtmlReporter.from-data(:%possible-lines, :%covered-lines).write(:$lib);
  #$index.flush;
}