unit class DataPart;

#| From what file the data is.
has Str $!file-name is built;
#| Map like: line-number => covered-times.
#| The map does not contain $!purple-lines.
has Map $!data is built;
#| Same map like $!data, but only for lines,
#| which is not coverable, but covered.
has Map $!purple-lines is built;

method new(DataPart:U: Str $file-name, Set :$coverable, Bag :$covered --> DataPart) {
	my Map $purple-lines := $covered.hash.grep({!$coverable{.key}}).Map;
	my $data := $covered.hash;
	$coverable.grep({!$covered{.key}}).map({$data{.key} = 0});
	self.bless(:$file-name, :$data, :$purple-lines);
}

method read(DataPart:U: Str $str --> DataPart) {
	my $split = $str.split('|')>>.trim;
	self.bless(
		file-name => $split[0],
		data => Hash[UInt, Any].new: $split[2].split(' ', :skip-empty)>>.Int,
		purple-lines => Hash[UInt, Any].new: ($split[3] // '').split(' ', :skip-empty)>>.Int,
	);
}