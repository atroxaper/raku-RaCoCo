use Test;
use lib 'lib';
use Racoco::Sha;

plan 4;

sub test($sha) {
  is $sha.uc('1ahs'), 'E82EFCCFBEB2F189ABB6D4BB79B02A20A277D04C', 'sha ok';
  is $sha.lc('1ahs'), 'e82efccfbeb2f189abb6d4bb79b02a20a277d04c', 'sha ok';
}

test(Racoco::Sha::Sha.new);
test(Racoco::Sha::create());

done-testing