unit module App::Racoco::Coverable::CoverableLinesSupplier;

use App::Racoco::Precomp::PrecompSupplier;
use App::Racoco::Precomp::PrecompHashcodeReader;
use App::Racoco::Coverable::CoverableIndex;
use App::Racoco::Coverable::Coverable;
use App::Racoco::Coverable::CoverableOutliner;

class CoverableLinesSupplier is export {
	has PrecompSupplier $.supplier;
  has CoverableIndex $.index;
  has CoverableOutliner $.outliner;
  has PrecompHashcodeReader $.hashcode-reader;

  method supply(Str :$file-name --> Set) {
    my $precomp-path = $!supplier.supply(:$file-name);
		return () unless $precomp-path;
    my $coverable = $!index.retrieve(:$file-name);
    unless self!is-coverable-actual($coverable, $precomp-path) {
			$coverable = self!calc-coverable($file-name, $precomp-path);
    	$!index.put(:$coverable);
    }
    $coverable.lines.Set
  }

  method !is-coverable-actual($coverable, $precomp-path) {
    $coverable && $precomp-path &&
    $coverable.timestamp >= $precomp-path.modified &&
    $coverable.hashcode eq $!hashcode-reader.read(path => $precomp-path)
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