use App::Racoco::Configuration;
use App::Racoco::RunProc;
use App::Racoco::Paths;
use App::Racoco::CoveredLinesCollector;
use App::Racoco::Coverable::Precomp::PrecompSupplier;
use App::Racoco::Coverable::Precomp::PrecompLookup;
use App::Racoco::Coverable::Precomp::Precompiler;
use App::Racoco::Coverable::CoverableIndex;
use App::Racoco::Coverable::CoverableOutliner;
use App::Racoco::Coverable::Precomp::PrecompHashcodeReader;
use App::Racoco::Coverable::CoverableLinesSupplier;
use App::Racoco::CoverableLinesCollector;
use App::Racoco::Report::Data;
use App::Racoco::Misc;

unit class App::Racoco is export;

has IO::Path $.root is required;
has Configuration $.config is required;
has Paths $!paths;
has RunProc $!proc;
has Data $!data;

submethod TWEAK {
	$!proc = RunProc.new;
	$!paths = make-paths-from(:$!config, :$!root);
}

method calculate-coverage(::?CLASS:D: --> App::Racoco:D) {
	my $covered-collector = self!create-covered-collector;
	my $coverable-collector = self!create-coverable-collector;
	if $!config<exec> {
		indir $!root, {
			my $previous-data = $!config{BoolKey.of: 'append'} ?? self!read-data !! Nil;
			my %covered = $covered-collector.collect();
			my %coverable = $coverable-collector.collect();
			$!data = Data.plus(Data.new(:%coverable, :%covered), $previous-data);
			$!data.write(:$!paths);
		}
	} else {
		$!data = self!read-data;
	}
	return self;
}

method !create-covered-collector() {
	my $result;
	indir $!root, {
		$result = CoveredLinesCollector.new(
			exec => $!config<exec>,
			print-test-log => !$!config{BoolKey.of: 'silent'},
			append => $!config{BoolKey.of: 'append'},
			:$!paths,
			:$!proc,
		);
	};
	return $result;
}

method !create-coverable-collector() {
	my $result;
	indir $!root, {
		my $raku = $!config{ExecutableInDirKey.of: 'raku-bin-dir', 'raku'};
		my $moar = $!config{ExecutableInDirKey.of: 'raku-bin-dir', 'moar'};
		my $precomp-supplier = PrecompSupplierReal.new(
			lookup => PrecompLookup.new(
				:$!paths, compiler-id => compiler-id(:$raku, :$!proc)
			),
			precompiler => Precompiler.new(:$!paths, :$raku, :$!proc)
		);
		my $index = CoverableIndexFile.new(:$!paths);
		my $outliner = CoverableOutlinerReal.new(:$!proc, :$moar);
		my $hashcode-reader = PrecompHashcodeReaderReal.new;
		my $coverable-supplier = CoverableLinesSupplier.new(
				supplier => $precomp-supplier, :$index, :$outliner, :$hashcode-reader
		);
		$result = CoverableLinesCollector.new(
				supplier => $coverable-supplier, :$!paths
		);
	};
	return $result;
}

method !read-data() {
  Data.read(:$!paths)
}

method do-report(::?CLASS:D: --> App::Racoco:D) {
	$!config{ReporterClassesKey.of: 'reporter'}
		.map({ $_.new.do(:$!paths, :$!data, :$!config) });
	return self;
}

method how-below-fail-level(::?CLASS:D: --> Int:D) {

	return -3;
}