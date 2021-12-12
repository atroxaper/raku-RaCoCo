unit class DataPart;

enum COLOR is export <GREEN RED NO>;

#| From what file the data is.
has Str $!file-name is built;
#| Percent of covered lines.
has Num $.percent;
#| Amount of covered lines.
has Int $.covered-amount;
#| Amount of coverable lines.
has Int $.coverable-amount;
#| Map like: line-number => covered-times.
#| The map does not contain $!purple-lines.
has Map $!data is built;
#| Same map like $!data, but only for lines,
#| which is not coverable, but covered.
has Map $!purple-lines is built;

method new(DataPart:U: Str $file-name, Set :$coverable, Bag :$covered --> DataPart) {
	my Map $purple-lines := $covered.hash.grep({!$coverable{.key}}).Map;
	my $covered-amount = $covered.elems;
	my $coverable-amount = $coverable.elems;
	my $data := $covered.hash;
	$coverable.grep({!$covered{.key}}).map({$data{.key} = 0});
	self.bless(
		:$file-name,
		:$covered-amount,
		:$coverable-amount,
		:$data,
		:$purple-lines
	);
}

method read(DataPart:U: Str $str --> DataPart) {
	my $split = $str.split('|')>>.trim;
	self.bless(
		file-name => $split[0],
		percent => $split[1].substr(0, *-1).Num,
		data => Hash[UInt, Any].new($split[2].split(' ', :skip-empty)>>.Int),
		purple-lines => Hash[UInt, Any].new(($split[3] // '').split(' ', :skip-empty)>>.Int)
	);
}

method percent(--> Num) {
	$!percent //= min 100, (($!covered-amount / $!coverable-amount) * 100 * 10).Int / 10;
}

method covered-amount(--> Int) {
	$!covered-amount //= $!data.grep(*.value != 0).elems + $!purple-lines.grep(*.value != 0).elems;
}

method coverable-amount(--> Int) {
	$!coverable-amount //= $!data.elems;
}

method color-of(Int :$line --> COLOR) {
	with self.hit-times-of(:$line) -> $amount {
		return $amount > 0 ?? GREEN !! RED
	}
	NO;
}

method hit-times-of(Int :$line --> Int) {
	$!data{$line} // $!purple-lines{$line} // Nil
}