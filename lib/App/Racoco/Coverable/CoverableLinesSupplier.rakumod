unit module App::Racoco::Coverable::CoverableLinesSupplier;

use App::Racoco::Precomp::PrecompSupplier;
use App::Racoco::Precomp::PrecompHashcodeReader;
use App::Racoco::Coverable::CoverableIndex;
use App::Racoco::Coverable::Coverable;
use App::Racoco::Coverable::CoverableOutliner;

constant \MOARVM = 'MOARVM';

class CoverableLinesSupplier is export {
	has PrecompSupplier $.supplier;
  has CoverableIndex $.index;
  has CoverableOutliner $.outliner;
  has PrecompHashcodeReader $.hashcode-reader;

  method supply(Str :$file-name --> Positional) {
    my $precomp-path = $!supplier.supply(:$file-name);
		return () unless $precomp-path;
    my $coverable = $!index.retrieve(:$file-name);
    unless self!is-coverable-actual($coverable, $precomp-path) {
			$coverable = self!calc-coverable($file-name, $precomp-path);
    	$!index.put(:$coverable) unless $coverable.hashcode eq MOARVM;
    }
    $coverable.lines
  }

  method !is-coverable-actual($coverable, $precomp-path) {
    $coverable && $precomp-path &&
    $coverable.hashcode eq $!hashcode-reader.read(path => $precomp-path) &&
    $coverable.hashcode ne MOARVM
  }

  method !calc-coverable($file-name, $precomp-path) {
  	Coverable.new(
    	:$file-name,
    	timestamp => $precomp-path.modified,
    	hashcode => $!hashcode-reader.read(path => $precomp-path),
    	lines => $!outliner.outline(path => $precomp-path)
    )
  }
}